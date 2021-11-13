import jsffi
import ../materials/material


type
  MeshBasicMaterial* {.importc.} = ref object of Material

proc newMeshBasicMaterial*(params: JsObject): MeshBasicMaterial {.
  importcpp: "new THREE.MeshBasicMaterial(@)", constructor.}
