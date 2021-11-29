import sequtils, random

const
  Healthy = true
  Broken = false
  Total = 1_000_000

proc p1(): int =
  var
    lamps = Broken.repeat(20) & Healthy.repeat(80)
    desired = 0

  for _ in 1..Total:
    lamps.shuffle()

    if lamps[0..<12].countIt(it == Broken) == 3:
      desired += 1

  desired


proc p2(): int =
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


for _ in 1..10:
  echo p1() / Total

echo "-----------------"

for _ in 1..10:
  echo p2() / Total
