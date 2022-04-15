import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";

const flowService = new FlowService();

async function testNFTCrossChain() {
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/SendCrossChainMessage.cdc'
    ),
    'utf8'
  );

  const authorization = flowService.authorizationFunction();

  const nftId = 0;

  await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(flowService.getSignerAddress(), types.Address),
      fcl.arg(nftId, types.UInt64)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

await testNFTCrossChain();