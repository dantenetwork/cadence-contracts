import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';

let signer = config.get('locker');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);

async function query() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/GetMetaData.cdc'
    ),
    'utf8'
  );

  // Passing in Number as value for UInt64 is deprecated and will cease to work in future releases of @onflow/types.
  // Going forward, use String as value for UInt64.
  const owner = config.get('emulator').address;
  const id = 1;

  const result = await flowService.executeScript({
    script: script,
    args: [
      fcl.arg(owner, types.Address),
      fcl.arg(JSON.stringify(id), types.UInt64)
    ]
  });
  console.log(result);
};

await query();

