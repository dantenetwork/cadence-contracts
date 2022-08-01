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
    signer = config.get('testnet-Bob');
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

// Get receiver from config/default.json
let receiver = config.get('emulator');
let locker = config.get('locker');

if (config.get('network') == 'testnet') {
    receiver = config.get('testnet-Bob');
    locker = config.get('testnet-Bob');
}

async function queryReceivedMessageVault(){
    // Query cross chain message from ethereum to flow
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/QueryReceivedMessage.cdc'
        ),
        'utf8'
    );

    const link = 'receivedMessageVault';

    const completeID = await flowService.executeScript({
        script: script,
        args: [
            fcl.arg(locker.address, types.Address),
            fcl.arg(link, types.String)
        ]
    });

    let lastCompleteID  = completeID['Ethereum'];
    if(!lastCompleteID || lastCompleteID == undefined){
        // -1 = receivedMessageVault is empty
        lastCompleteID = 0;
    }
    await queryCrossChainPending(lastCompleteID);
}

// Query locked NFT on Rinkeby
async function queryCrossChainPending(lastCompleteID) {
    // Query cross chain transfer pending info
    let messages = await ethereum.contractCall(NFTContract, 'queryCrossChainPending', []);
    // console.log(messages);
    console.log('message length: ' + messages.length);
    console.log('lastCompleteID: ' + parseInt(lastCompleteID));
    // console.log('lastCompleteID: ' + (parseInt(lastCompleteID) + 1));
    if(messages.length > lastCompleteID){
        const message = messages[lastCompleteID];
        console.log(message);
        console.log('Sync message from Rinkeby to Flow');
        await crossChainMint(parseInt(lastCompleteID) + 1, message[0], message[1], message[2], message[3]);
        await queryReceivedMessageVault();
    }else{
        console.log('sleep 3 seconds');
        setTimeout(async () => {
            await queryReceivedMessageVault();
        }, 3000);
    }
}

// cross chain mint NFT from Rinkeby to Flow
async function crossChainMint(msgID, tokenId, receiver, tokenURL, randomNumberHash) {
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
            fcl.arg(config.get("emulator").address, types.Address), // Locker contract address
            fcl.arg(msgID, types.UInt128),
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
            fcl.arg(msgID, types.UInt128),
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

await queryReceivedMessageVault();