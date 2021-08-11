# Package

version       = "0.1.0"
author        = "hamidb80"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["threejs"]


# Dependencies

requires "nim >= 1.5.1"

task rundev, "builds the program":
  exec "nim js -o:build/main.js src/main.nim"