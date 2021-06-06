import math, stats, os, strformat, sequtils, times
import pixie
import screenshot, keyboard

import benchy

# import times,strformat,stats
# var tlist: seq[float]
# let tstart = cpuTime()
# tlist.add cpuTime() - tstart

var num = 0
const stickColor = ColorRGBX(r:135, g: 158, b:164, a:255)

converter u2i(n:uint8): int=
  int n

converter i2f(n:int): float32=
  float32 n

proc `~=`(c1,c2: ColorRGBX): bool=
  [abs(c1.r - c2.r), abs(c1.b - c2.b), abs(c1.g - c2.g)].mean < 40 

const (x,y, w, h) = (1325,1025, 105,95)

while true:
  let st = cpuTime()

  var img = takeScreenshot()
  let cropLeft = img.subImage(x,y,w,h)
  
  let keyToEnter=
    if cropLeft.data.countIt( it ~= stickColor ) > 40: rightArrow
    else: leftArrow
  
  pressAndRelease keyToEnter

  let
    pos = vec2(x, y)
    wh = vec2(w,h)

  img.fillRect(rect(pos, wh), rgba(255, 0, 0, 255))
  img.writeFile fmt"log/l{num}.png"
  inc num

  let et = cpuTime()
  echo fmt"delay: {et- st}"