import jsffi, dom
import lib/[
  scenes/scene, cameras/perspectiveCamera, renderers/webGLRenderer,
  geometries/boxGeometry, materials/meshBasicMaterial,
  objects/mesh,
  math/euler,
  utils
]

let
  s = newScene()
  camera = newPerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
  renderer = newWebGLRenderer()

setSize(renderer, window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

let c = newJsObject()
c.color = 0x00ff00

let
  geometry = newBoxGeometry()
  material = newMeshBasicMaterial(c)
  cube = newMesh(geometry, material)

s.add(cube)
camera.position.z = 5

proc animate() =
  requestAnimationFrame(animate)

  cube.rotation.x += 0.01
  cube.rotation.y += 0.01

  renderer.render(s, camera)

animate()