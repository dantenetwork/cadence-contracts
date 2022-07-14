import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import config from 'config';

let signer = config.get('locker');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

async function createCollection() {
  // Read mint transaction cdc
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/SetupAccount.cdc'
    ),
    'utf8'
  );

  let response = await flowService.sendTx({
    transaction,
    args: [
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });

  console.log('Tx Sent:', response);

  console.log('The new NFT has been minted, waiting for the transaction to be sealed..');
  await fcl.tx(response).onceSealed();
  console.log('Transaction sealed.');
}

await createCollection();