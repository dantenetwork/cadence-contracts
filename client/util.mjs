import fs from 'fs';
import path from 'path';
import FlowService from './flow.mjs';
import config from 'config';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);

class Util {
    queryTotalSupply = async () => {
        const script = fs.readFileSync(
            path.join(
                process.cwd(),
                './transactions/nft/QueryTotalSupply.cdc'
            ),
            'utf8'
        );

        let totalSupply = await flowService.executeScript({
            script: script,
            args: []
        });
        return totalSupply;
    }
}

export default Util;