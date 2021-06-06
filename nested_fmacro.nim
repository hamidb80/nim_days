import
  macros, sequtils, strutils
import 
  macroutils except Lit

macro forNest(infixExpr: untyped, body: untyped): untyped =
  assert:
    infixExpr.len != 0 and
    infixExpr.kind == nnkInfix

  var
    itrtors = infixExpr[1]
    dest = infixExpr[2]

  result = superQuote:
    for `itrtors[0]` in 0..<`dest`.len:
      nothing

  var forBody = result
  for c in 1..<itrtors.len:
    dest = superQuote: `dest`[`itrtors[c-1]`]

    forBody[2] = superQuote:
      for `itrtors[c]` in 0..<`dest`.len:
        nothing

    forBody = forBody[2]

  forBody[2] = body
  return result

macro newNestedSeqWith(s: openArray[int], defaultValue: untyped): untyped =
  assert s.len >= 1

  result = superQuote: newSeqWith(`s[0]`, defaultValue)

  var argptr = result
  for i in s[1..^1]:
    argptr[2] = quote: newSeqWith(`i`, `defaultValue`)
    argptr = argptr[2]
  
let matrix = [
  [1, 2],
  [3, 4],
  [5, 6]
]

var res = newNestedSeqWith([matrix[0].len, matrix.len], 0)
forNest [y, x] in matrix:
  res[x][y] = matrix[y][x]

echo (res.mapIt it.join" ").join "\n"