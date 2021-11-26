import std/[strutils, os, json]
import ./blockchain
import jester

let blkchain = initBlockChain()

router myrouter:
  get "/mine_block":
    resp %*{
      "message": "Congratulations, you just mined a block little fella!",
      "block": % blkchain.mineBlock
    }

  # Return the full blkchain
  get "/get_chain":
    resp %*{
      "chain": blkchain.chain,
      "length": blkchain.chain.len
    }

  # Check to see if the chain is valid
  get "/is_valid":
    let msg = 
      if is_chain_valid(blkchain.chain):
        "The blkchain is valid!"
      else:
        "The blkchain is invalid!"
    
    resp %*{"message": msg}

# ------------------------------------

proc main() =
  let port = paramStr(1).parseInt().Port
  let settings = newSettings(port=port)
  var jester = initJester(myrouter, settings=settings)
  jester.serve()

when isMainModule:
  main()