import pixie, chroma, strformat, threadpool

proc hueImage(img: Image, degs: float): Image =
  result = img
  template clr: untyped = result.data[i]
  
  for i in 0..<img.data.len:
    clr = clr.asColor.spin(degs).asRgbx
proc my(img: Image, deg: float, saveName:string) {.inline.}=
  img.hueImage(deg).writeFile saveName

let img = readImage "./sample.png"

for i in 0..<24:
  spawn my(img, 360 / 24 * float i, fmt"./res{i}.png")

sync()