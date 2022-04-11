import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';

const address = config.get('address');
const privateKey = config.get('privateKey');
const keyId = config.get('keyId');

const flowService = new FlowService(
  address,
  privateKey,
  keyId
);

async function testNFTCrossChain() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/SendCrossChainMessage.cdc'
    ),
    'utf8'
  );

  const authorization = flowService.authorizationFunction();

  const id = 0;

  await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(address, types.Address),
      fcl.arg(id, types.UInt64)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

await testNFTCrossChain();