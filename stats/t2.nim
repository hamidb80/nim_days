import sequtils, sugar, strutils
import formula

let points = collect newseq:
  for k in 0..100:
    (k.float, poisson(100, k, 0.05))

echo points.map(`$`).join "\n"
showInDiagram points
