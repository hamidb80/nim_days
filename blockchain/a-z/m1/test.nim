import unittest, sequtils, strformat
import ./blockchain

let blkchain = initBlockChain()

test "/mine_block":
  let
    previous_block = blkchain.last()
    previous_proof = previous_block.proof
    proof = proof_of_work(previous_proof)
    previous_hash = hash(previous_block)
    b = blkchain.addBlock(proof, previous_hash)

  echo b[]

# Return the full blkchain
test "/get_chain":
  echo blkchain.chain.mapIt($it[])

# Check to see if the chain is valid
test "/is_valid":
  check is_chain_valid(blkchain.chain)