import times, math, json
import nimsha2

type
  Block* = ref object
    index*: int
    proof*: int
    timestamp*: string
    previous_hash*: string
    transactions*: seq[Transaction]

  Chain* = seq[Block]

  Transaction* = ref object
    sender, receiver: string
    amount: float

  BlockChain* = ref object
    chain*: Chain
    transactions*: seq[Transaction]

func `$`*(blk: Block): string =
  pretty %*blk[]

func `$`*(bc: BlockChain): string =
  pretty %*bc

proc newBlock(proof: int, preHash: string): Block =
  result = new Block
  result.proof = proof
  result.timestamp = $now()
  result.previous_hash = preHash

proc registerBlock*(bc: BlockChain, blk: Block) =
  blk.index = bc.chain.len + 1
  blk.transactions = bc.transactions
  bc.transactions.setLen 0
  bc.chain.add blk

proc initBlockChain*: BlockChain =
  result = new BlockChain
  result.registerBlock newBlock(1, "0")

func lastBlock*(bc: BlockChain): Block =
  bc.chain[^1]

func newTransaction*(sendr, recvr: string, amnt: float): Transaction =
  result = new Transaction
  result.sender = sendr
  result.receiver = recvr
  result.amount = amnt

proc addTransaction*(bc: BlockChain, tr: Transaction): int =
  bc.transactions.add tr
  bc.lastBlock.index

func pphash*(newp, prevp: int): string =
  hex computeSHA256 $(newp^2 - prevp^2)

func proofOfWork*(previous_proof: int): int =
  var new_proof = 1

  while true:
    let hash_operation = pphash(new_proof, previous_proof)

    if hash_operation[0 ..< 4] == "0000":
      return new_proof

    new_proof.inc


func hash*(b: Block): string =
  hex computeSHA256( $ b[])

func isChainValid*(chain: Chain): bool =
  for i in 1 .. chain.high:
    let
      b = chain[i]
      prev_b = chain[i-1]

    if b.previous_hash != hash(prev_b):
      debugEcho "hash consistency"
      return false

    let hash_operation = pphash(b.proof, prev_b.proof)
    if hash_operation[0..<4] != "0000":
      debugEcho "hash limit"
      return false

  true

proc mineBlock*(bc: BlockChain): Block =
  let
    previous_block = bc.lastBlock
    previous_proof = previous_block.proof
    proof = proof_of_work previous_proof

  result = newBlock(proof, bc.lastBlock.hash)
  bc.registerBlock result

proc replaceChain*(bc: BlockChain, newchain: Chain): bool =
  if (bc.chain.len < newchain.len) and isChainValid(newchain):
    bc.chain = newchain
    return true
