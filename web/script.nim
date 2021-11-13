include karax / prelude
# import karax / [kbase, vdom, kdom, vstyles, karax, karaxdsl, jdict, jstrutils, jjson]

import jscore, jsutils

var lines: seq[kstring] = @[]


proc createDom(): VNode =
  result = buildHtml(tdiv):
    button:
      text "Say hello!"
      proc onclick(ev: Event; n: VNode) =
        lines.add "Hello simulated universe"
    
    for x in lines:
      tdiv:
        text x

setRenderer createDom