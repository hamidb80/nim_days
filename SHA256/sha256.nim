import
  sequtils, strutils,
  algorithm, math,
  os

func `xor`*(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len, $(a, b)
  for i in 0..<a.len:
    result.add a[i] xor b[i]

func `+`*(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len
  var carry = 0
  for i in countdown(a.len-1, 0):
    let sum = carry + a[i].int + b[i].int
    result.insert (sum mod 2).bool, 0
    carry = sum div 2

func `and`*(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len
  for i in 0..<a.len:
    result.add (a[i] == b[i]) and a[i]

func `not`*(s: seq[bool]): seq[bool] =
  s.mapIt not it

template rotatedRight[T](a: seq[T], b: int): untyped =
  a.rotatedLeft -b

func rightShifted*[T](s: seq[T]; num: Natural): seq[T] =
  repeat(false, num) & s[0..<s.len-num]

func groupEvery*[T](s: seq[T]; num: Natural): seq[seq[T]] =
  for n in countup(0, s.len-1, num):
    result.add s[n..<n+num]

func toSeqBool*(s: string): seq[bool]{.inline.} =
  s.mapIt it == '1'

func toSeqBool*(s: openArray[int]): seq[bool]{.inline.} =
  s.mapIt it == 1

func toInt*(s: seq[bool]): int64 =
  for i in 0..<s.len:
    result += s[^(i+1)].int * (2^(i))

const zeroList = [0, 0, 0, 0, 0, 0, 0, 0].toSeqBool

func toBinary*(num: int | int64; chunkBy = 8): seq[seq[bool]] {.inline.} =
  var
    numc = num
    binaryRepr: seq[bool]

  while numc != 0:
    binaryRepr.insert bool(numc mod 2), 0
    numc = numc div 2

  let mustAdd = block:
    let t = binaryRepr.len mod chunkBy
    if t == 0: 0
    else: chunkBy - t

  binaryRepr.insert repeat(false, mustAdd), 0
  binaryRepr.groupEvery(chunkBy)

func strToBinarySeq*(word: string): seq[seq[bool]] {.inline.} =
  word.mapIt it.ord.toBinary[0]

func add1toEnd(binarySeq: seq[seq[bool]]): seq[seq[bool]] {.inline.} =
  binarySeq & [1, 0, 0, 0, 0, 0, 0, 0].toSeqBool

func to512diviableMinus64*(binarySeq: seq[seq[bool]]): seq[seq[bool]] {.inline.} =
  let remaining = block:
    let
      t = (binarySeq.len * 8) mod 512
      r = (512 - 64 - t)

    if r < 0: r + 512
    else: r

  binarySeq & repeat(zeroList, remaining div 8)

func `$`*(s: seq[bool]): string =
  s.mapIt(if it: 1 else: 0).join

func `$`*(s: seq[seq[bool]]): string =
  s.mapIt($it)
    .distribute(s.len div 2).mapIt(it.join " ")
    .join "\n"

const
  hashes = [
    0x6a09e667'i64, 0xbb67ae85,
    0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c,
    0x1f83d9ab, 0x5be0cd19
  ].mapIt it.toBinary.concat
  roundK = [
    0x428a2f98'i64, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ].mapIt it.toBinary(8*4).concat

func sha256*(s: string): string =
  let length = (s.len * 8).toBinary(64)[0]
  var
    table =
      s
      .strToBinarySeq
      .add1toEnd
      .to512diviableMinus64 & length.groupEvery(8)

    hs = hashes

  for chunk in table.groupEvery(8*8):

    var words: seq[seq[bool]]
    for i in countup(0, chunk.len-1, 4):
      words.add concat(chunk[i..i+3])

    for i in 16..<64:
      let
        s0 =
          (words[i-15].rotatedRight 7) xor
          (words[i-15].rotatedRight 18) xor
          (words[i-15].rightShifted 3)
        s1 =
          (words[i-2].rotatedRight 17) xor
          (words[i-2].rotatedRight 19) xor
          (words[i-2].rightShifted 10)

      words.add s0 + s1 + words[i-7] + words[i-16]

    var (a, b, c, d, e, f, g, h) = (
      hs[0], hs[1], hs[2], hs[3], hs[4], hs[5], hs[6], hs[7])

    for i in 0..<64:
      let
        s0 =
          (a.rotatedRight 2) xor
          (a.rotatedRight 13) xor
          (a.rotatedRight 22)

        s1 =
          (e.rotatedRight 6) xor
          (e.rotatedRight 11) xor
          (e.rotatedRight 25)

        ch = (e and f) xor ((not e) and g)
        temp1 = h + s1 + ch + roundK[i] + words[i]

        maj = (a and b) xor (a and c) xor (b and c)
        temp2 = s0 + maj

      (h, g, f, e, d, c, b, a) = (g, f, e, d + temp1, c, b, a, temp1 + temp2)

    for (i, v) in [a, b, c, d, e, f, g, h].pairs:
      hs[i] = v + hs[i]

  hs.mapIt(it.toInt.toHex 8).join


if isMainModule:
  if paramCount() != 2:
    echo "usage: "
    echo "app -s \"your string\""
    echo "app -f \"your file name\""

  else:
    let inp =
      if paramStr(1) == "-f": readFile paramStr(2)
      else: paramStr(2)

    echo sha256 inp
