import fs from 'fs';
import path from 'path';
import FlowService from './flow.mjs';

const flowService = new FlowService(
  'f8d6e0586b0a20c7',
  'efe24d3e3b5652c0d056e52b7fe592fef8e94dba26e1dfd945c7f66958731e19',
  0
)

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

  await flowService.sendTx({
    transaction,
    args: [],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

// await setupAccount();
await mintNFT();