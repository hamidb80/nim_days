import std/[sequtils, strutils, asyncdispatch, os, json, times]
import nimsha2, jester

router myrouter:
  get "/":
    resp "It's alive!"

proc main() =
  let port = paramStr(1).parseInt().Port
  let settings = newSettings(port=port)
  var jester = initJester(myrouter, settings=settings)
  jester.serve()

when isMainModule:
  main()