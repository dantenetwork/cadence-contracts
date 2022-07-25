import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';

const flowService = new FlowService();

async function query() {
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/QueryLockerMessage.cdc'
        ),
        'utf8'
    );

    const result = await flowService.executeScript({
        script: script,
        args: []
    });
    console.log(result);
};

await query();

