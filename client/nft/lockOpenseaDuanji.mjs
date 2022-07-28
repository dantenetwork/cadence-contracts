import fs from 'fs';
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
// read private key
const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();
let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = config.get('ethereumContract');
// TODO
// for debugging purpose, should be removed on the production environment
const randomNumberHash = config.get('randomNumberHash');

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

console.log('Initating cross chain sync service...');

// Get receiver from config/default.json
let receiver = config.get('emulator').address;

const tokenId = process.argv[2];
console.log('tokenId: ' + tokenId);

if(tokenId && tokenId > 0){
    console.log('Submit cross chain transfer to ethereum');

    // Submit cross chain transfer from ethereum to flow
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainTransfer', ethPrivateKey, [tokenId, receiver, randomNumberHash]);
    console.log('blockHash: ' + ret.blockHash);
}else{
    console.log('Please input valid NFT id');
}