import jsffi

type
  Euler* {.importc.} = ref object of JsObject
    x*, y*, z*: float

proc newEuler*(x,y,z: float, order: cstring = "XYZ"): Euler {.importcpp: "new THREE.Euler(@)", constructor.}