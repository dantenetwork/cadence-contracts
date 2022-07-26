import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';

let signer = config.get('emulator');
if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

// TODO
// for debugging purpose, should be removed on the production environment
const randomNumber = config.get('randomNumber');

// Claim cross chain NFT on FLow
async function crossChainClaim(){
    // Submit claim message 
    const transaction = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/ClaimNFT.cdc'
        ),
        'utf8');

    const id = 1;    
    console.log('randomNumber: ' + randomNumber);

    let response = await flowService.sendTx({
        transaction,
        args: [
            fcl.arg(JSON.stringify(id), types.UInt64),
            fcl.arg(randomNumber, types.String)
        ],
        proposer: authorization,
        authorizations: [authorization],
        payer: authorization
    });

    console.log('Tx Sent:', response);

    console.log('Waiting for the transaction to be sealed.');
    await fcl.tx(response).onceSealed();
    console.log('Transaction sealed.');
}

await crossChainClaim();