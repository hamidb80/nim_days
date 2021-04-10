import
  sequtils, strutils,
  algorithm, math,
  unittest

func `xor`(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len, $(a, b)
  for i in 0..<a.len:
    result.add a[i] xor b[i]

func `+`(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len
  var carry = 0
  for i in countdown(a.len-1, 0):
    let sum = carry + a[i].int + b[i].int
    result.insert (sum mod 2).bool, 0
    carry = sum div 2

func `and`(a, b: seq[bool]): seq[bool] =
  doAssert a.len == b.len
  for i in 0..<a.len:
    result.add (a[i] == b[i]) and a[i]

func `not`(s: seq[bool]): seq[bool] =
    s.mapIt not it


func rightshifted[T](s: seq[T]; num: Natural): seq[T] =
  repeat(false, num) & s[0..<s.len-num]

func groupEvery[T](s: seq[T]; num: Natural): seq[seq[T]] =
  for n in countup(0, s.len-1, num):
    result.add s[n..<n+num]

func toSeqBool(s: string): seq[bool]{.inline.} =
  s.mapIt it == '1'

func toSeqBool(s: openArray[int]): seq[bool]{.inline.} =
  s.mapIt it == 1

func toInt(s: seq[bool]): int64=
  for i in 0..<s.len:
    result += s[^(i+1)].int * (2^(i))

const zeroList = [0, 0, 0, 0, 0, 0, 0, 0].toSeqBool

func intToBinary(num: int | int64, chunk = 8): seq[seq[bool]] {.inline.} =
  var
    numc = num
    binaryRepr: seq[bool]

  while numc != 0:
    binaryRepr.insert bool(numc mod 2), 0
    numc = numc div 2

  let mustAdd = block:
    let t = binaryRepr.len mod chunk
    if t == 0: 0
    else: chunk - t  

  binaryRepr.insert repeat(false, mustAdd), 0
  binaryRepr.groupEvery(chunk)

func strToBinarySeq(word: string): seq[seq[bool]] {.inline.} =
  word.mapIt it.ord.intToBinary[0]

func add1toEnd(binarySeq: seq[seq[bool]]): seq[seq[bool]] {.inline.} =
  binarySeq & [1, 0, 0, 0, 0, 0, 0, 0].toSeqBool

func to512diviableMinus64(binarySeq: seq[seq[bool]]): seq[seq[bool]] {.inline.} =
  let remaining = (binarySeq.len * 8) mod 512

  binarySeq & repeat(zeroList, (512 - 64 - remaining) div 8)

func `$`(s: seq[bool]): string =
  s.mapIt(if it: 1 else: 0).join

func `$`(s: seq[seq[bool]]): string =
  s.mapIt($it)
    .distribute(s.len div 2).mapIt(it.join " ")
    .join "\n"


const
  hashes = [
    0x6a09e667'i64,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ].mapIt it.intToBinary.concat
  roundK = [
    0x428a2f98'i64,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2
  ].mapIt it.intToBinary(8*4).concat

func sha256(s: string): string =
  let t = (s.len * 8).intToBinary
  var table8x8x8 = concat([
    s.strToBinarySeq.add1toEnd.to512diviableMinus64,
    repeat(zeroList, 8 - t.len) & t])

  var table16x32: seq[seq[bool]]
  for i in countup(0, table8x8x8.len-1, 4):
    table16x32.add concat(table8x8x8[i..i+3])

  doAssert table16x32.len == 16

  for i in 16..<64:
    let
      s0 =
        (table16x32[i-15].rotatedLeft -7) xor
        (table16x32[i-15].rotatedLeft -18) xor
        (table16x32[i-15].rightshifted 3)
      s1 =
        (table16x32[i-2].rotatedLeft -17) xor
        (table16x32[i-2].rotatedLeft -19) xor
        (table16x32[i-2].rightshifted 10)

    table16x32.add s0 + s1 + table16x32[i-7] + table16x32[i-16]


  var (a, b, c, d, e, f, g, h) = (
    hashes[0],
    hashes[1],
    hashes[2],
    hashes[3],
    hashes[4],
    hashes[5],
    hashes[6],
    hashes[7]
  )

  for i in 0..<64:
    let     
      s0 = 
        (a.rotatedLeft -2) xor
        (a.rotatedLeft -13) xor
        (a.rotatedLeft -22)

      s1 = 
        (e.rotatedLeft -6) xor
        (e.rotatedLeft -11) xor
        (e.rotatedLeft -25)

      ch = (e and f) xor ((not e) and g)

      temp1 = h + s1 + ch + roundK[i] + table16x32[i]
      maj = (a and b) xor (a and c) xor (b and c)
      temp2 = s0 + maj

    h = g
    g = f
    f = e
    e = d + temp1
    d = c
    c = b
    b = a
    a = temp1 + temp2 

  return [
        a + hashes[0],
        b + hashes[1],
        c + hashes[2],
        d + hashes[3],
        e + hashes[4],
        f + hashes[5],
        g + hashes[6],
        h + hashes[7],
    ].mapIt(it.toInt.toHex(8)).join


proc main =
  let inp =
    # "hello world"
    stdin.readLine.strip

  echo sha256 inp

main()
# ------ test -------

test "intToBinary":
  check 001.intToBinary == @[[0, 0, 0, 0, 0, 0, 0, 1].toSeqBool]
  check 088.intToBinary == @[[0, 1, 0, 1, 1, 0, 0, 0].toSeqBool]
  check 127.intToBinary == @[[0, 1, 1, 1, 1, 1, 1, 1].toSeqBool]
  check 280.intToBinary == @[
    [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool,
    [0, 0, 0, 1, 1, 0, 0, 0].toSeqBool
  ]

test "to512diviableMinus64":
  check to512diviableMinus64(@[
    [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool
  ]).len == 56

  check to512diviableMinus64(
    [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool.repeat(56)
  ).len == 56

  check to512diviableMinus64(
    [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool.repeat(64)
  ).len == 120

test "rightHsifted":
  check "01101111001000000111011101101111".toSeqBool.rightshifted(3) ==
      "00001101111001000000111011101101".toSeqBool

test "+":
  check (
         "01101000011001010110110001101100".toSeqBool +
         "11001110111000011001010111001011".toSeqBool
    ) == "00110111010001110000001000110111".toSeqBool

test "not":
  check "11101001".toSeqBool.not == "00010110".toSeqBool

test "sha256":
  check "hello world".sha256 == "B94D27B9934D3E08A52E52D7DA7DABFAC484EFE37A5380EE9088F7ACE2EFCDE9"