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

  await flowService.sendTx({
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
}

await mintNFT();