import times, json
import nimsha2

type
  Block* = ref object
    index*: int
    proof*: int
    timestamp*: string
    previous_hash*: string

  BlockChain* = ref object
    chain*: seq[Block]

proc `^`(x, n: int): int =
  result = 1
  for _ in 1..n:
    result *= x

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

  bc.chain.add result

proc initBlockChain*: BlockChain =
  result = new BlockChain
  discard result.addBlock(1, "0")

proc last*(bc: BlockChain): Block = bc.chain[^1]

proc pphash*(newp, prevp: int): string =
  hex computeSHA256 $(newp^2 - prevp^2)

proc proofOfWork*(previous_proof: int): int =
  var
    new_proof = 1
    check_proof = false

  while not check_proof:
    let hash_operation = pphash(new_proof, previous_proof)

    if hash_operation[0 ..< 4] == "0000":
      check_proof = true
    else:
      new_proof.inc

  new_proof

proc hash*(b: Block): string =
  hex computeSHA256( $ % b)

proc isChainValid*(chain: seq[Block]): bool =
  var
    previous_block = chain[0]
    block_index = 1

  while block_index < chain.len:
    let b = chain[block_index]

    if b.previous_hash != hash(previous_block):
      return false

    let
      previous_proof = previous_block.proof
      proof = b.proof
      hash_operation = pphash(proof, previous_proof)

    if hash_operation[0..<4] != "0000":
      return false

    previous_block = b
    block_index += 1

  true
