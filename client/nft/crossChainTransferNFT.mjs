import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import crypto from 'crypto';
import config from 'config';
import Util from '../util.mjs';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

const util = new Util();

async function mintNFT() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/CrossChainTransferNFT.cdc'
    ),
    'utf8'
  );

  var totalSupply = await util.queryTotalSupply();
  const tokenId = parseInt(totalSupply);
  console.log('tokenId: ' + tokenId);

  // Generate random number
  let randomNumber = Buffer.from(crypto.randomBytes(32)).toString('hex');

  // TODO
  // for debugging purpose, should be removed on the production environment
  randomNumber = config.get('randomNumber');
  console.log('Random number: ' + randomNumber);

  const hashValue = '0x' + crypto.createHash('sha256').update(randomNumber).digest('hex');
  console.log('hashValue: ' + hashValue);

  const owner = config.get('ethereumReceiver'); 

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(JSON.stringify(tokenId), types.UInt64),
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