import sequtils, random

const
  Healthy = true
  Broken = false
  Total = 1_000_000

proc p6(): int =
  var
    lamps = Broken.repeat(20) & Healthy.repeat(80)
    desired = 0

  for _ in 1..Total:
    lamps.shuffle()

    if lamps[0..<12].countIt(it == Broken) == 3:
      desired += 1

  desired


proc p5_1(): int =
  var desired = 0
  for _ in 1..Total:
    let broken =
      (1..12)
      .toseq()
      .mapIt(rand 1..100)
      .filterIt(it <= 20)
      .len

    if broken == 3:
      desired += 1

  desired


proc p5_2(): int =
  var desired = 0
  for _ in 1..Total:
    let broken = 
      (1..100)
      .toseq()
      .mapIt((rand 1..100) <= 20)[0..<12]
      .countIt(it == true)

    if broken == 3:
      desired += 1

  desired

# ------------------------------------------------

template calc(title, fn): untyped =
  echo "<<< ", title, " >>>"

  for _ in 1..10:
    echo fn() / Total
  

calc "p5_1", p5_1
calc "p5_2", p5_2
calc "p6", p6