import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import config from 'config';

const address = config.get('address');
const privateKey = config.get('privateKey');
const keyId = config.get('keyId');

const flowService = new FlowService(
  address,
  privateKey,
  keyId
);

async function query() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QueryCrossChainMessage.cdc'
    ),
    'utf8'
  );

  const id = 0;

  const result = await flowService.executeScript({
    script: script,
    args: []
  });
  console.log(result);
};

await query();

