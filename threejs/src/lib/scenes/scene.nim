import ../core/object3D

type
  Scene {.importc.} = ref object of Object3D
    autoUpdate*: bool

proc newScene*(): Scene {.importcpp: "new THREE.Scene()", constructor.}