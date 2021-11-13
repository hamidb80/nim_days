import sequtils, sugar, strutils
import formula

let points = collect newseq:
  for n in 0..30:
    (n.float, bernoulliTrial(30, n, 0.4))

echo points.map(`$`).join "\n"
showInDiagram points
