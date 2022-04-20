import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";

const flowService = new FlowService();

const authorization = flowService.authorizationFunction();

async function mintNFT() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/MintNFT.cdc'
    ),
    'utf8'
  );

  const NFTName = 'Flow Blockchain';
  const NFTDescription = 'Flow Blockchain';
  const NFTThumbnail = 'https://file.publish.vn/amberblocks/2021-10/flow-ecosystem-1635519453417.png';

  var id = await queryNFTCount();
  id++;
  console.log('Sending mint transaction, NFT id ' + id);

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(flowService.getSignerAddress(), types.Address),
      fcl.arg(NFTName, types.String),
      fcl.arg(NFTDescription, types.String),
      fcl.arg(NFTThumbnail, types.String)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });

  console.log('Tx Sent:', response);


  console.log('The new NFT has been minted and will be automatically synchronized to the rinkeby testnet in a few seconds.');
  console.log('https://testnets.opensea.io/assets/0xe524839f9CD9Eb9b3Cb166511Ba5179179ce65e8/' + id);

  console.log('Waiting for the transaction to be sealed.');
  await fcl.tx(response).onceSealed();
  console.log('Transaction sealed.');
}

async function queryNFTCount() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QuerySentMessage.cdc'
    ),
    'utf8'
  );

  let result =  await flowService.executeScript({
    script: script,
    args: []
  });
  return result.length;
};

await mintNFT();