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

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

console.log('Initating cross chain sync service...');

// Get receiver from config/default.json
let receiver = config.get('emulator').address;

// Get input params
const tokenId = process.argv[2];
const randomNumberHash = process.argv[3];
console.log('tokenId: ' + tokenId);

if(tokenId > 0 && randomNumberHash != ''){
    console.log('Submit cross chain transfer to ethereum');

    // Submit cross chain transfer from ethereum to flow
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainTransfer', ethPrivateKey, [tokenId, receiver, randomNumberHash]);
    console.log('blockHash: ' + ret.blockHash);
}else{
    console.log('Please input valid NFT id and random number hash value');
}