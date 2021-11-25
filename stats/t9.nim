import sugar
import formula


proc drawFuncWith(probability: float) =
  let points = collect newseq:
    for k in 0..100:
      (k.float, poisson(100, k, probability))

  showInDiagram points


for p in [0.3, 0.5, 0.9]:
  drawFuncWith p
