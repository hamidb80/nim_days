import sequtils, math, strutils, random
import bigints, plotly, chroma

randomize()

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

converter validPoint*(p: tuple[x: int, y: float]): Point =
  (p.x.float, p.y)
  
proc rcch: float = 
  ## random color channel
  rand(0.8) + 0.1
  
proc randColor(): Color =
  Color(r: rcch(), g: rcch(), b: rcch(), a: 1.0)

proc showInDiagram*(lines: varargs[seq[Point]]) =
  show Plot[float](
    layout: Layout(width: 1200, height: 400),
    traces: lines.mapit(Trace[float](
      mode: PlotMode.LinesMarkers,
      `type`: PlotType.Scatter,
      marker: Marker[float](size: @[16.0], color: @[randColor()]),
      xs: it.mapit it[0],
      ys: it.mapit it[1]
  )))
