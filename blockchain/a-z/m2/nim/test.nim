import std/[unittest, sequtils, oids, random]
import ./blockchain

# utils ------------------------------------

randomize()

proc newArbitaryTransaction: Transaction =
  newTransaction($genOid(), $genOid(), rand(1.0))

proc genTransactions(bc: BlockChain, max: int) =
  for _ in 1..max: # transactions of a block
    discard bc.addTransaction newArbitaryTransaction()

# tests ------------------------------------

suite "block chain functionality":
  let bc = initBlockChain()

  test "init":
    check bc.chain.len == 1

  test "add transaction":
    let newtr = newTransaction("me", "you", 0.2)
    discard bc.addTransaction newtr
    check bc.transactions[^1] == newtr
    check bc.transactions.len == 1

  test "mine_block":
    bc.genTransactions 3
    discard bc.mineBlock
    check bc.chain.len == 2

  # Check to see if the chain is valid
  test "is_valid":
    # TODO also etst not valid
    check is_chain_valid(bc.chain)

  test "replace chain":
    var chains: seq[Chain] = @[bc.chain]
    for n in 1..6:
      let tmpBC = initBlockChain()
      
      for blockCount in 1..rand(1..10): # gen block
        tmpBC.genTransactions rand(2..12)
        discard tmpBC.mineBlock
        debugecho "progress: ", (chain: n, `block`: blockCount)

      chains.add tmpBC.chain

    doAssert chains.allIt(it.isChainValid)
    let largetsChain = chains[chains.mapIt(it.len).maxIndex()]
    check chains.anyIt bc.replaceChain(it)
    check bc.chain.len == largetsChain.len
    check bc.chain == largetsChain

  test "echo block":
    # echo bc
    echo bc.lastBlock
