import jsffi

type
  BufferGeometry* {.importc.} = ref object of JsObject

proc newBufferGeometry*(): BufferGeometry {.importcpp: "new THREE.BufferGeometry()", constructor.}
