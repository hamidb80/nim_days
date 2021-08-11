import jscore, jsffi

type
  Scene {.importc.} = ref object of JsObject 
    autoUpdate*: bool

proc newScene*(): Scene {.importc: "new Scene(@)", constructor.}
