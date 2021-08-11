import jsffi
import ../materials/material
import ../core/[bufferGeometry, object3D]

type
  Mesh* {.importc.} = ref object of Object3D

proc newMesh*(
   geometry: BufferGeometry, material: Material
): Mesh {.importcpp: "new THREE.Mesh(@)", constructor.}
