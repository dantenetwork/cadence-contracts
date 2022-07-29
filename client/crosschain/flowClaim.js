import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import config from 'config';
import Util from '../util.mjs';

let signer = config.get('emulator');
if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

// Claim cross chain NFT on FLow
async function crossChainClaim(){
    // Submit claim message 
    const transaction = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/ClaimFlowNFT.cdc'
        ),
        'utf8');

    let response = await flowService.sendTx({
        transaction,
        args: [
            fcl.arg(tokenId, types.UInt64),
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

// Get input params
const tokenId = process.argv[2];
const randomNumber = process.argv[3];

console.log('tokenId: ' + tokenId);
if(tokenId > 0 && randomNumber != ''){
    await crossChainClaim(tokenId, randomNumber);
}else{
    console.log('Please input valid NFT id & random number');
}