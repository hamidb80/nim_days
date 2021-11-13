import jsffi, dom

type
  WebGLRenderer {.importc.} = ref object of JsObject
    domElement*: Node

proc newWebGLRenderer*(): WebGLRenderer {.importcpp: "new THREE.WebGLRenderer()", constructor.}
proc setSize*(r: WebGLRenderer, w, h: int, full: bool = true) {.importcpp.}
