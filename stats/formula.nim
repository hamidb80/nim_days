import sequtils, math, strutils
import bigints, plotly, chroma

func fact(n: Natural): Bigint =
  if n == 0: initbigint 1
  else: (1..n).toSeq.mapIt(it.initbigint).foldl a * b

template `!`*(n): untyped = fact n
template `^`*(n, x): untyped = pow n.float, x.float

func combination(n, k: Natural): BigInt =
  !n div (!k * !(n-k))

converter toFloat(n: BigInt): float = n.toString.parseFloat
template c*(n, k): untyped = combination(n, k)
template q: untyped {.dirty.} = 1.0 - p

func bernoulliTrial*(n, k: Natural, p: float): float =
  c(n, k) * (p ^ k) * (q ^ (n - k))

func poisson*(n, k: Natural, p: float): float =
  let a = n.float * p
  (E ^ -a) * (a ^ k) / !k

# ---------------------------------------------------

type Point* = tuple[x, y: float]

proc showInDiagram*(points: openArray[Point]) =
  let d = Trace[float](
    mode: PlotMode.LinesMarkers,
    `type`: PlotType.Scatter,
    marker: Marker[float](size: @[16.0], color: @[
      Color(r: 0.9, g: 0.4, b: 0.0, a: 1.0)]),
    xs: points.mapit it[0],
    ys: points.mapit it[1]
  )

  Plot[float](
    layout: Layout(width: 1200, height: 400),
    traces: @[d]
  ).show()
