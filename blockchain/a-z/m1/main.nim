import std/[strutils, os, json]
import ./blockchain
import jester

let blkchain = initBlockChain()

router myrouter:
  get "/mine_block":
    let
      previous_block = blkchain.last()
      previous_proof = previous_block.proof
      proof = proof_of_work(previous_proof)
      previous_hash = hash(previous_block)
      b = blkchain.addBlock(proof, previous_hash)

    resp %*{
      "message": "Congratulations, you just mined a block little fella!",
      "block": %b
    }

  # Return the full blkchain
  get "/get_chain":
    resp %*{
      "chain": blkchain.chain,
      "length": len(blkchain.chain)
    }

  # Check to see if the chain is valid
  get "/is_valid":
    resp(
      if is_chain_valid(blkchain.chain):
        %*{"message": "The blkchain is valid!"}
      else:
        %*{"message": "The blkchain is invalid!"}
    )

proc main() =
  let port = paramStr(1).parseInt().Port
  let settings = newSettings(port=port)
  var jester = initJester(myrouter, settings=settings)
  jester.serve()

when isMainModule:
  main()