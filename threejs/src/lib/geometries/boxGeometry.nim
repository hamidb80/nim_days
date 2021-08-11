import jsffi
import ../core/bufferGeometry

type
  BoxGeometry* {.importc.} = ref object of BufferGeometry

proc newBoxGeometry*(
  width, height, depth: float = 1.0, 
  widthSegments, heightSegments, depthSegments: int = 1
): BoxGeometry {.importcpp: "new THREE.BoxGeometry(@)", constructor.}
