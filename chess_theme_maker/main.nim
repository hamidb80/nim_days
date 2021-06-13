import json, os
import pixie, chroma

const outputPath = "./output/"

type
  InputData = object
    picturePaths: tuple[
      pawn, rook, knight, bishop, queen, king: string]

    themes: seq[tuple[
      name, whiteColor, blackColor: string]]


func replaceImageColor(img: Image, newColor: ColorRGBX): Image =
  result = img
  template pxl: untyped = result.data[i]

  for i in 0..<result.data.len:
    pxl = ColorRGBX(
      r: newColor.r,
      g: newColor.g,
      b: newColor.b,
      a: pxl.a)


if isMainModule:
  let data = "./input.json".readFile.parseJson.to InputData

  if dirExists outputPath: removeDir outputPath
  createDir outputPath


  for theme in data.themes:
    let themeDest = outputPath/theme.name
    createDir themeDest

    for (pname, ppath) in [
      ("pawn", data.picturePaths.pawn),
      ("rook", data.picturePaths.rook),
      ("knight", data.picturePaths.knight),
      ("bishop", data.picturePaths.bishop),
      ("queen", data.picturePaths.queen),
      ("king", data.picturePaths.king)]:

      let img = readImage ppath
      replaceImageColor(img,
        theme.whiteColor[1..^1].parseHex.asRgbx).writeFile(themeDest/(pname & "-white.png"))
      replaceImageColor(img,
        theme.blackColor[1..^1].parseHex.asRgbx).writeFile(themeDest/(pname & "-black.png"))
