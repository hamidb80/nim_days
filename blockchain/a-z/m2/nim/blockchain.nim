import times, json, math
import nimsha2

type
  Block* = ref object
    index*: int
    proof*: int
    timestamp*: string
    previous_hash*: string
    transactions: seq[Transaction]

  Transaction* = ref object
    sender, receiver: string
    amount: float

  BlockChain* = ref object
    chain*: seq[Block]
    transactions: seq[Transaction]


proc newBlock*(i: int, proof: int, ts: string, preHash: string): Block =
  result = new Block
  result.index = i
  result.proof = proof
  result.timestamp = ts
  result.previous_hash = preHash

proc addBlock*(bc: BlockChain, proof: int, previous_hash: string): Block =
  result = newBlock(
    bc.chain.len + 1,
    proof,
    $now(),
    previous_hash
  )
  result.transactions = bc.transactions

  bc.transactions.setLen 0
  bc.chain.add result

proc initBlockChain*: BlockChain =
  result = new BlockChain
  discard result.addBlock(1, "0")

proc lastBlock*(bc: BlockChain): Block =
  bc.chain[^1]

proc newTransaction*(sendr, recvr: string, amnt: float): Transaction =
  result = new Transaction
  result.sender = sendr
  result.receiver = recvr
  result.amount = amnt

proc addTransaction*(bc: BlockChain, sendr, recvr: string, amnt: float): int =
  bc.transactions.add newTransaction(sendr, recvr, amnt)
  bc.lastBlock.index + 1

proc pphash*(newp, prevp: int): string =
  hex computeSHA256 $(newp^2 - prevp^2)

proc proofOfWork*(previous_proof: int): int =
  var new_proof = 1

  while true:
    let hash_operation = pphash(new_proof, previous_proof)

    if hash_operation[0 ..< 4] == "0000":
      return new_proof

    new_proof.inc


proc hash*(b: Block): string =
  hex computeSHA256( $ % b)

proc isChainValid*(chain: seq[Block]): bool =
  for i in 1 .. chain.high:
    let
      b = chain[i]
      prev_b = chain[i-1]

    if b.previous_hash != hash(prev_b):
      return false

    let hash_operation = pphash(b.proof, prev_b.proof)
    if hash_operation[0..<4] != "0000":
      return false

  true

proc mineBlock*(bc: BlockChain): Block =
  let
    previous_block = bc.lastBlock
    previous_proof = previous_block.proof
    proof = proof_of_work previous_proof

  bc.addBlock(proof, previous_block.hash)
