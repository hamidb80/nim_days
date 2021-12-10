import std/[strutils, os, json, strformat]
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
    let result =
      if is_chain_valid(blkchain.chain): "valid"
      else: "invalid"

    resp %*{"message": fmt"The blkchain is {result}!"}


  # Adding a new transaction to the Blockchain
  # post "/add_transaction":
  #   json = request.get_json()
  #   transaction_keys = ["sender", "receiver", "amount"]
  #   if not all(key in json for key in transaction_keys):
  #       return "Some elements of the transaction are missing", 400
  #   index = blockchain.add_transaction(
  #       json["sender"], json["receiver"], json["amount"])
  #   response = {"message": f"This transaction will be added to Block {index}"}
  #   return jsonify(response), 201

  # Connecting new nodes
  # post "/connect_node":
  #   json = request.get_json()
  #   nodes = json.get("nodes")
  #   if nodes is None:
  #       return "No node", 400
  #   for node in nodes:
  #       blockchain.add_node(node)
  #   response = {"message": f"All the nodes are now connected. The Rogercoin blockchain now contains the following nodes:",
  #               "total_nodes": list(blockchain.nodes)}
  #   return jsonify(response), 201

  # Replacing the chain by the longest chain if needed
  # get "/replace_chain":
  #     is_valid_replaced = blockchain.replace_chain()
  #     if is_valid_replaced:
  #         response = {"message": "The nodes had different chains so the chain was replaced by the longest one.",
  #                     "new_chain": blockchain.chain}
  #     else:
  #         response = {"message": "All good. The chain is the largest one.",
  #                     "actual_chain": blockchain.chain}
  #     return jsonify(response), 200

  

# ------------------------------------

proc main() =
  let port = paramStr(1).parseInt().Port
  let settings = newSettings(port = port)
  var jester = initJester(myrouter, settings = settings)
  jester.serve()

when isMainModule:
  main()
