import jsffi

type
  PerspectiveCamera {.importc.} = ref object of JsObject

proc newPerspectiveCamera*(fov, aspect, near, far: float
): PerspectiveCamera {.importcpp: "new THREE.PerspectiveCamera(@)", constructor.}

# newJsObject