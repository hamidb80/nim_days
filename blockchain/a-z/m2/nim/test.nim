import unittest, sequtils, strformat
import ./blockchain

let bc = initBlockChain()

test "/mine_block":
  let b = mineBlock bc
  echo fmt"{b[] =}"

  check bc.chain.len == 2

# Return the full bc
test "/get_chain":
  echo bc.chain.mapIt($it[])

# Check to see if the chain is valid
test "/is_valid":
  check is_chain_valid(bc.chain)