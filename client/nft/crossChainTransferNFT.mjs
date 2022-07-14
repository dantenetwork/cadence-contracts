import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import crypto from 'crypto';
import config from 'config';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

async function mintNFT() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/CrossChainTransferNFT.cdc'
    ),
    'utf8'
  );

  const id = 2;

  // Generate random number
  const randomNumber = Buffer.from(crypto.randomBytes(256)).toString('hex');
  console.log('Random number: ' + randomNumber);

  const hashValue = crypto.createHash('sha256').update(randomNumber).digest('hex');
  console.log('hashValue: ' + hashValue);

  const owner = '0x3aE841B899Ae4652784EA734cc61F524c36325d1'; 

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(JSON.stringify(id), types.UInt64),
      fcl.arg(owner, types.String),
      fcl.arg(hashValue, types.String)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });

  console.log('Tx Sent:', response);

  console.log('Waiting for the transaction to be sealed.');
  await fcl.tx(response).onceSealed();
  console.log('Transaction sealed.');
}
await mintNFT();