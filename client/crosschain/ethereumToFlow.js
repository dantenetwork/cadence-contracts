import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from './ethereum.js';
import config from 'config';
import Util from '../util.mjs';


const flowService = new FlowService();

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

async function crossChainTransfer(){
    console.log('Submit cross chain transfer to ethereum');
    // Query last NFT id
    var totalSupply = await util.queryTotalSupply();
    const tokenId = totalSupply;
    console.log('tokenId: ' + tokenId);

    // Submit cross chain transfer from ethereum to flow
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainTransfer', ethPrivateKey, [tokenId, receiver, randomNumberHash]);
    console.log('blockHash: ' + ret.blockHash);

    // Query cross chain transfer pending info
    let result = await ethereum.contractCall(NFTContract, 'queryCrossChainPending', [tokenId]);
    console.log(result);
}

await crossChainTransfer();