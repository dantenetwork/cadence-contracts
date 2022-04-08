import fs from 'fs';
import path from 'path';
import FlowService from './flow.mjs';
import config from 'config';

const address = config.get('address');
const privateKey = config.get('privateKey');
const keyId = config.get('keyId');

const flowService = new FlowService(
  address,
  privateKey,
  keyId
);

async function run() {
  const transaction = fs
    .readFileSync(
      path.join(
        process.cwd(),
        './transactions/testGreeting.cdc'
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

run();