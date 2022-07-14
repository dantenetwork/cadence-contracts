import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

async function mintNFT() {
  // Read mint transaction cdc
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/MintNFT.cdc'
    ),
    'utf8'
  );

  const tokenURL = 'https://raw.githubusercontent.com/wuyahuang/opensea/main/1';

  var totalSupply = await queryTotalSupply();
  console.log('totalSupply: ' + totalSupply);

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(flowService.getSignerAddress(), types.Address),
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
}

async function queryTotalSupply() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QueryTotalSupply.cdc'
    ),
    'utf8'
  );

  let totalSupply = await flowService.executeScript({
    script: script,
    args: []
  });
  return totalSupply;
};

await mintNFT();