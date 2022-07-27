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

// TODO
// for debugging purpose, should be removed on the production environment
const randomNumber = config.get('randomNumber');

const util = new Util();

// Claim cross chain NFT on FLow
async function crossChainClaim(){
    // Submit claim message 
    const transaction = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/ClaimFlowNFT.cdc'
        ),
        'utf8');

    // Query last NFT id
    var totalSupply = await util.queryTotalSupply();
    const tokenId = totalSupply;
    console.log('tokenId: ' + tokenId);
    console.log('randomNumber: ' + randomNumber);

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

await crossChainClaim();