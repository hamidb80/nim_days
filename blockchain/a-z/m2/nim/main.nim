import std/[strutils, os, json, strformat]
import blockchain, helper, network
import jester

let
  blkchain = initBlockChain()
  nt = initNetwork()

router myrouter:
  get "/mine_block":
    resp %*{
      "message": "Congratulations, you just mined a block little fella!",
      "block": % blkchain.mineBlock}

  # Return the full blkchain
  get "/get_chain":
    resp %*{
      "chain": blkchain.chain,
      "length": blkchain.chain.len}

  # Check to see if the chain is valid
  get "/is_valid":
    let msg =
      if blkchain.chain.is_chain_valid(): "valid"
      else: "invalid"

    resp %*{"message": fmt"The blkchain is {msg}!"}

  # Adding a new transaction to the Blockchain
  post "/add_transaction":
    let data = parseJson @"payload"
    var tr: Transaction

    try:
      tr = data.to(Transaction)
    except JsonKindError:
      resp Http400, %*{"error": "request body is not valid"}

    let index = blkchain.addTransaction tr
    resp Http201, %*{"message": fmt"This transaction will be added to Block {index}"}

  # Connecting new nodes
  post "/connect_node":
    let data = parseJson @"payload"

    for nodeUrl in data["nodes"].to(seq[string]):
      nt.addNode(nodeUrl)

    resp Http201, %*{"total_nodes": nt.nodes}

  # Replacing the chain by the longest chain if needed
  get "/replace_chain":
    if await nt.replace_chain(blkchain):
      resp Http201, %*{
        "message": "The nodes had different chains so the chain was replaced by the longest one.",
        "new_chain": blkchain.chain}

    else:
      resp Http200, %*{
        "message": "All good. The chain is the largest one.",
        "actual_chain": blkchain.chain}

# ------------------------------------

proc main =
  let port = paramStr(1).parseInt().Port
  let settings = newSettings(port = port)
  var jester = initJester(myrouter, settings = settings)
  jester.serve()

when isMainModule:
  main()
