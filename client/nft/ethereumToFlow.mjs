import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import fcl from "@onflow/fcl";
import types from "@onflow/types";
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';
import Util from '../util.mjs';

let signer = config.get('emulator');
if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}

const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);
const authorization = flowService.authorizationFunction();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
// read private key
const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();

let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = config.get('ethereumContract');

// TODO
// for debugging purpose, should be removed on the production environment
const randomNumber = config.get('randomNumber');
const randomNumberHash = config.get('randomNumberHash');

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();
const util = new Util();

console.log('Initating cross chain sync service...');
console.log();

// Get receiver from config/default.json
let receiver = config.get('emulator');

if (config.get('network') == 'testnet') {
    receiver = config.get('testnet');
}

async function crossChainTransfer() {
    console.log('Submit cross chain transfer to ethereum');
    // Query last NFT id
    var totalSupply = await util.queryTotalSupply();
    const tokenId = totalSupply;
    console.log('tokenId: ' + tokenId);

    // Submit cross chain transfer from ethereum to flow
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainTransfer', ethPrivateKey, [tokenId, receiver, randomNumberHash]);
    console.log('blockHash: ' + ret.blockHash);

    // Query cross chain transfer pending info
    console.log();
    console.log('Query pending cross chain message from Ethereum to Flow');
    let result = await ethereum.contractCall(NFTContract, 'queryCrossChainPending', [tokenId]);
    console.log(result);

    crossChainMint(tokenId);
}

async function crossChainMint(tokenId) {
    // Submit received message 
    const transaction = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/ReceivedMessage.cdc'
        ),
        'utf8');

    const id = tokenId;
    const fromChain = 'Ethereum';
    const toChain = 'Flow';
    const sqosString = '1';
    const receiver = '0xf8d6e0586b0a20c7';
    const publicPath = 'calleeVault';
    const sessionId = 1;
    const sessionType = 1;
    const sessionCallback = 'ea621511fa72955ecf79bf41d1b29896f053efb03e907dab63b9f15322d81839';
    const sessionCommitment = 'ea621511fa72955ecf79bf41d1b29896f053efb03e907dab63b9f15322d81839';
    const sessionAnswer = 1;


    let utf8Encode = new TextEncoder();
    const originData = new Uint8Array(utf8Encode.encode(JSON.stringify(id)));
    // TODO
    // add more params into originData

    console.log(originData);
    // const toChainBytes = utf8Encode.encode(toChain);
    // originData.set(toChainBytes, originData.length);
    // console.log(originData);
    // originData = originData.fill(utf8Encode.encode(fromChain));
    // originData = originData.fill(utf8Encode.encode(toChain));
    // originData = originData.fill(utf8Encode.encode(signer));
    // originData = originData.concat(utf8Encode.encode(sqosString));
    // originData = originData.concat(utf8Encode.encode(receiver));
    // originData = originData.concat(utf8Encode.encode(publicPath));
    // originData = originData.concat(utf8Encode.encode(hashValue));
    // originData = originData.concat(utf8Encode.encode(sessionId));
    // originData = originData.concat(utf8Encode.encode(sessionType));
    // originData = originData.concat(utf8Encode.encode(sessionCallback));
    // originData = originData.concat(utf8Encode.encode(sessionCommitment));
    // originData = originData.concat(utf8Encode.encode(sessionAnswer));

    const msg = Buffer.from(originData).toString("hex");

    // sign message
    // hash = SHA3_256
    // elliptic = ECDSA_P256
    console.log('msg: ' + msg);
    const signature = await flowService.signWithKey(signer.privateKey, msg);
    console.log('signature: ' + signature);

    let response = await flowService.sendTx({
        transaction,
        args: [
            fcl.arg(JSON.stringify(id), types.UInt128),
            fcl.arg(fromChain, types.String),
            fcl.arg(toChain, types.String),
            fcl.arg(sqosString, types.String),
            fcl.arg(JSON.stringify(id), types.UInt64),
            fcl.arg(receiver, types.Address),
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

async function queryReceivedMessage() {
    console.log('Query received message');
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/QueryReceivedMessage.cdc'
        ),
        'utf8'
    );

    const result = await flowService.executeScript({
        script: script,
        args: []
    });
    console.log(JSON.stringify(result));
}

// await crossChainTransfer();
await crossChainMint(1);
await queryReceivedMessage();