import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";

const flowService = new FlowService();

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
  const id = JSON.stringify(0);

  const result = await flowService.executeScript({
    script: script,
    args: [
      fcl.arg(flowService.getSignerAddress(), types.Address),
      fcl.arg(id, types.UInt64)
    ]
  });
  console.log(result);
};

await query();

