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

async function query() {

  const address = '0xf8d6e0586b0a20c7';

  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/GetMetaData.cdc'
    ),
    'utf8'
  );

  const id = 0;

  const result = await flowService.executeScript({
    script: script,
    args: [
      fcl.arg(address, types.Address),
      fcl.arg(id, types.UInt64)
    ]
  });
  console.log(result);
};

await query();

