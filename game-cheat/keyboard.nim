when defined(windows):
  import winlean
else:
  {.error: "not supported os".}

type
  InputType = enum
    itMouse itKeyboard itHardware
  KeyEvent = enum
    keExtendedKey = 0x0001
    keKeyUp = 0x0002
    keUnicode = 0x0004
    keScanCode = 0x0008


  MouseInput {.importc: "MOUSEINPUT".} = object
    dx, dy: clong
    mouseData, dwFlags, time: culong
    dwExtraInfo: int # ULONG_PTR

  KeybdInput {.importc: "KEYBDINPUT".} = object
    wVk, wScan: cint
    dwFlags, time: culong
    dwExtraInfo: int

  HardwareInput {.importc: "HARDWAREINPUT".} = object
    uMsg: clong
    wParamL, wParamH: cint

  InputUnion {.union.} = object
    hi: HardwareInput
    mi: MouseInput
    ki: KeybdInput
  Input = object
    `type`: clong
    hwin: InputUnion

proc sendInput(total: cint, inp: ptr Input, size: cint) {.importc: "SendInput",
    header: "<windows.h>".}

proc initKey(keycode: int): Input =
  result = Input(`type`: itKeyboard.clong)
  var keybd = KeybdInput(wVk: keycode.cint, wScan: 0, time: 0,
    dwExtraInfo: 0, dwFlags: 0)
  result.hwin = InputUnion(ki: keybd)

proc pressKey(input: var Input) =
  input.hwin.ki.dwFlags = keExtendedKey.culong
  sendInput(cint 1, addr input, sizeof(Input).cint)

proc releaseKey(input: var Input) =
  input.hwin.ki.dwFlags = keExtendedKey.culong or keKeyUp.culong
  sendInput(cint 1, addr input, sizeof(Input).cint)

proc pressRelease(input: var Input) =
  input.pressKey
  input.releaseKey

proc pressReleaseKeycode(input: var Input, code: int) =
  input.hwin.ki.wVk = code.cint
  input.pressRelease

var keybInp = initKey 0xa0 # VK_LSHIFT
const
  rightArrow* = 39
  leftArrow* = 37

proc pressAndRelease*(keyCode: int) =
  keybInp.pressReleaseKeycode keyCode
