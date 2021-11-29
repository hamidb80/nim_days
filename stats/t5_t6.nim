import sequtils, random
import formula

const
  Healthy = true
  Broken = false
  Size = 100
  B = 80
  H = Size - B
  Total = 1_000_000

func toseq(n: int): seq[int] = (1..n).toseq

proc p6(Select, Desired: int): float =
  var lamps = Broken.repeat(B) & Healthy.repeat(H)

  for _ in 1..Total:
    lamps.shuffle()

    if lamps[0..<Select].countIt(it == Broken) == Desired:
      result += 1

  result / Total


proc p5_1(Select, Desired: int): float =
  for _ in 1..Total:
    let broken =
      Select
      .toseq()
      .mapIt(rand 1..Size)
      .countIt(it <= B)

    if broken == Desired:
      result += 1

  result / Total

proc p5_2(Select, Desired: int): float =
  for _ in 1..Total:
    let broken =
      (1..Size)
      .toseq()
      .mapIt((rand 1..Size) <= B)[0..<Select]
      .countIt(it == true)

    if broken == Desired:
      result += 1

  result / Total

# ----------------------------------

when isMainModule:
  import formula
  randomize()
  
  const select = 12
  var rp5, rp6: seq[Point]

  for desired in 1..select:
    rp5.add (desired, p5_1(select, desired))
    rp6.add (desired, p6(select, desired))

  echo rp5, rp6
  showInDiagram rp5, rp6