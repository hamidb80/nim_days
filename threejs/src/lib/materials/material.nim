import jsffi

type
  Material* {.importc.} = ref object of JsObject
