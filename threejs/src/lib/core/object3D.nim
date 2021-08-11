import jsffi
import ../math/euler

type
  Object3D* {.importc.} = ref object of JsObject
    rotation*: Euler

proc add*(self: Object3D, obj: varargs[JsObject]) {.importcpp.}

