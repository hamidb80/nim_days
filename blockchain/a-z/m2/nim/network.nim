import std/[httpclient, asyncdispatch, uri, json]
import ./blockchain

type Network* = ref object
  nodes*: seq[string]

proc initNetwork*: Network=
  new Network

proc addNode*(nt: Network, url: string) =
  doAssert parseUri(url).isAbsolute
  nt.nodes.add(url)

proc replaceChain*(nt: Network, bc: BlockChain): Future[bool] {.async.} =
  let hc = newAsyncHttpClient()

  var
    longestChain: seq[Block]
    maxChainLength = bc.chain.len

  for url in nt.nodes:
    let resp = await hc.get url

    if resp.code.is2xx:
      let
        data = parseJson await resp.body
        length = data["length"].to(int)
        chain = data["chain"].to(seq[Block])

      if (length > maxChainLength) and isChainValid(chain):
        maxChainLength = length
        longestChain = chain

  return
    if longestChain.len != 0:
      bc.chain = longestChain
      true
    else:
      false
