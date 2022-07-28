import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';

let signer = config.get('emulator');
if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = config.get('ethereumContract');
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

console.log('Initating cross chain sync service...');

// Get receiver from config/default.json
let receiver = config.get('emulator');

if (config.get('network') == 'testnet') {
    receiver = config.get('testnet');
}

// Query locked NFT on Rinkeby
async function queryCrossChainPending(tokenId) {
    // Query cross chain transfer pending info
    console.log('Query pending cross chain message from Ethereum to Flow');
    let pendingInfo = await ethereum.contractCall(NFTContract, 'queryCrossChainPending', [tokenId]);
    console.log(pendingInfo);

    if(pendingInfo[0] != '' && pendingInfo[1] != '' && pendingInfo[2] != ''){
        crossChainMint(pendingInfo[0], pendingInfo[1], pendingInfo[2]);
    }else{
        console.log('tokenId ' + tokenId + ' is not locked yet');
    }
}

// cross chain mint NFT from Rinkeby to Flow
async function crossChainMint(tokenId, receiver, tokenURL, hashValue) {
    const fromChain = 'Ethereum';
    const toChain = 'Flow';
    const sqosString = '1';
    const publicPath = 'calleeVault';
    const sessionId = 1;
    const sessionType = 1;
    const sessionCallback = 'ea621511fa72955ecf79bf41d1b29896f053efb03e907dab63b9f15322d81839';
    const sessionCommitment = 'ea621511fa72955ecf79bf41d1b29896f053efb03e907dab63b9f15322d81839';
    const sessionAnswer = 1;

    // Genereate digest
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/GenerateDigest.cdc'
        ),
        'utf8'
    );
    let createdData = await flowService.executeScript({
        script: script,
        args: [
            fcl.arg(signer.address, types.Address),
            fcl.arg(config.get("locker").address, types.Address),
            fcl.arg(tokenId, types.UInt128),
            fcl.arg(fromChain, types.String),
            fcl.arg(toChain, types.String),
            fcl.arg(sqosString, types.String),
            fcl.arg(tokenId, types.UInt64),
            fcl.arg(receiver, types.String),
            fcl.arg(publicPath, types.String),
            fcl.arg(hashValue, types.String),
            fcl.arg(JSON.stringify(sessionId), types.UInt128),
            fcl.arg(JSON.stringify(sessionType), types.UInt8),
            fcl.arg(sessionCallback, types.String),
            fcl.arg(JSON.stringify(sessionCommitment), types.String),
            fcl.arg(JSON.stringify(sessionAnswer), types.String)
        ]
    });
    const rawData = createdData.rawData;
    const toBeSign = createdData.toBeSign;

    console.log('rawData: ' + rawData);
    console.log('toBeSign: ' + toBeSign);

    const message = Buffer.from(toBeSign).toString("hex");
    console.log('message: ' + message);

    // sign message
    // hash = SHA3_256
    // elliptic = ECDSA_P256
    const signature = await flowService.signWithKey(signer.privateKey, message);
    console.log('signature: ' + signature);

    // Submit received message 
    const transaction = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/ReceivedMessage.cdc'
        ),
        'utf8');

    let response = await flowService.sendTx({
        transaction,
        args: [
            fcl.arg(tokenId, types.UInt128),
            fcl.arg(fromChain, types.String),
            fcl.arg(toChain, types.String),
            fcl.arg(sqosString, types.String),
            fcl.arg(tokenId, types.UInt64),
            fcl.arg(receiver, types.String),
            fcl.arg(publicPath, types.String),
            fcl.arg(randomNumberHash, types.String),
            fcl.arg(JSON.stringify(sessionId), types.UInt128),
            fcl.arg(JSON.stringify(sessionType), types.UInt8),
            fcl.arg(sessionCallback, types.String),
            fcl.arg(JSON.stringify(sessionCommitment), types.String),
            fcl.arg(JSON.stringify(sessionAnswer), types.String),
            fcl.arg(signature, types.String),
        ],
        proposer: authorization,
        authorizations: [authorization],
        payer: authorization
    });
    console.log(response);
}

const tokenId = process.argv[2];
console.log('tokenId: ' + tokenId);
if(tokenId && tokenId > 0){
    await queryCrossChainPending(tokenId);
}else{
    console.log('Please input valid NFT id');
}