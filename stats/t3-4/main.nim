import sequtils, random

const
  Healthy = true
  Broken = false
  Total = 1_000_000
  Select = 12
  Desired = 3
  Repeat = 3

func toseq(n: int): seq[int] = (1..n).toseq

proc p6(): int =
  var lamps = Broken.repeat(20) & Healthy.repeat(80)

  for _ in 1..Total:
    lamps.shuffle()

    if lamps[0..<Select].countIt(it == Broken) == Desired:
      result += 1


proc p5_1(): int =
  for _ in 1..Total:
    let broken =
      Select
      .toseq()
      .mapIt(rand 1..100)
      .filterIt(it <= 20)
      .len

    if broken == Desired:
      result += 1


proc p5_2(): int =
  for _ in 1..Total:
    let broken =
      (1..100)
      .toseq()
      .mapIt((rand 1..100) <= 20)[0..<Select]
      .countIt(it == true)

    if broken == Desired:
      result += 1

# ------------------------------------------------

template calc(title, fn): untyped =
  echo "<<< ", title, " >>>"

  for _ in 1..Repeat:
    echo fn() / Total


calc "p5_1", p5_1
calc "p5_2", p5_2
calc "p6", p6
