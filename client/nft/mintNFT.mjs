import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Util from '../util.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

const util = new Util();

async function mintNFT() {
  // Read mint transaction cdc
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/MintNFT.cdc'
    ),
    'utf8'
  );

  const description = 'Punster Mint Test';
  const tokenURL = 'https://raw.githubusercontent.com/wuyahuang/opensea/main/1';

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(description, types.String),
      fcl.arg(tokenURL, types.String)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });

  console.log('Tx Sent:', response);

  console.log('The new NFT has been minted, waiting for the transaction to be sealed..');
  await fcl.tx(response).onceSealed();
  console.log('Transaction sealed.');
  
//   var totalSupply = await util.queryTotalSupply();
//   console.log('totalSupply: ' + totalSupply);
}

await mintNFT();