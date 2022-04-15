import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';


const flowService = new FlowService();
const authorization = flowService.authorizationFunction();

async function destroy() {
  const transaction = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/ResetSentMessageVault.cdc'
    ),
    'utf8'
  );

  await flowService.sendTx({
    transaction,
    args: [],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  });
};

await destroy();

