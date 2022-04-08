import fs from 'fs';
import path from 'path';
import FlowService from './flow.mjs';
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

async function setupAccount() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/SetupAccount.cdc'
    ),
    'utf8'
  );

  const authorization = flowService.authorizationFunction();

  await flowService.sendTx({
    transaction,
    args: [],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

async function mintNFT() {
  // setup account
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/MintNFT.cdc'
    ),
    'utf8'
  );

  const authorization = flowService.authorizationFunction();

  const NFTName = 'NFT Name';
  const NFTDescription = 'NFT Description';
  const NFTThumbnail = 'NFT Thumbnail';
  console.log(111);

  await flowService.sendTx({
    transaction,
    args: [
      fcl.arg(address, types.Address),
      fcl.arg(NFTName, types.String),
      fcl.arg(NFTDescription, types.String),
      fcl.arg(NFTThumbnail, types.String)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

// await setupAccount();
await mintNFT();