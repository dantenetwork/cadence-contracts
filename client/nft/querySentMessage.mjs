import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';

const flowService = new FlowService();

async function query() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QuerySentMessage.cdc'
    ),
    'utf8'
  );

  const result = await flowService.executeScript({
    script: script,
    args: []
  });
  
  for(let item of result){
    console.log(item);
    console.log('sqos: ' + JSON.stringify(item.msgToSubmit.sqos));
    console.log('data: ' + JSON.stringify(item.msgToSubmit.data));
    console.log();
  }
};

await query();

