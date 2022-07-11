import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import crypto from 'crypto';

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
  console.log();
  console.log('New NFT Info: ');
  console.log(NFTName);
  console.log(NFTDescription);
  console.log(NFTThumbnail);
  console.log();

  // Generate random number
  const randomNumber = Buffer.from(crypto.randomBytes(256)).toString('hex');
  console.log('Random number: ' + randomNumber);

  const commitment = crypto.createHash('sha256').update(randomNumber).digest('hex');
  console.log('Commitment: ' + commitment);

  const receiver = '0x3aE841B899Ae4652784EA734cc61F524c36325d1';

  var id = await queryNFTCount();
  id++;
  console.log('Sending mint transaction, NFT id ' + id);

  let response = await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(flowService.getSignerAddress(), types.Address),
      fcl.arg(NFTName, types.String),
      fcl.arg(NFTDescription, types.String),
      fcl.arg(NFTThumbnail, types.String),
      fcl.arg(receiver, types.String),
      fcl.arg(commitment, types.String)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });

  console.log('Tx Sent:', response);


  console.log('The new NFT has been minted and will be automatically synchronized to the rinkeby testnet in a few seconds.');
  console.log('https://testnets.opensea.io/assets/0x0DdD135645EC1C65b0595E7dad271F616926D5B2/' + id);

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

  let result = await flowService.executeScript({
    script: script,
    args: []
  });
  return result.length;
};

await mintNFT();