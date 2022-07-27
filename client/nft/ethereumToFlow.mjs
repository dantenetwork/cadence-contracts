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

    // // Submit received message 
    // const transaction = fs.readFileSync(
    //     path.join(
    //         process.cwd(),
    //         './transactions/nft/signatureVerify.cdc'
    //     ),
    //     'utf8');

    // // Verify signature
    // let response = await flowService.executeScript({
    //     script: transaction,
    //     args: [
    //         fcl.arg(rawData, types.String),
    //         fcl.arg("bb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025", types.String),
    //         fcl.arg(signature, types.String),
    //         fcl.arg(signer.address, types.Address)
    //     ],
    // });
    // console.log(response);


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
// Query last NFT id
var totalSupply = await util.queryTotalSupply();
const tokenId = totalSupply;
console.log('tokenId: ' + tokenId);

await crossChainMint(tokenId);
await queryReceivedMessage();