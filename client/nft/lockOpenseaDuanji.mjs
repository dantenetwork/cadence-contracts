import fs from 'fs';
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
// read private key
const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();
// console.log(web3.eth.accounts.privateKeyToAccount(ethPrivateKey));
let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = config.get('ethereumContract');

let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();
// 0x3aE841B899Ae4652784EA734cc61F524c36325d1

// Get receiver from config/default.json
let receiver = config.get('emulator').address;

// Get input params
const tokenId = process.argv[2];
const randomNumberHash = process.argv[3];
console.log('tokenId: ' + tokenId);

if(tokenId > 0 && randomNumberHash != ''){
    try{
        const owner = await ethereum.contractCall(NFTContract, 'ownerOf', [tokenId]);
        console.log('NFT owner: ' + owner);

        console.log('Submit cross chain transfer to ethereum');

        console.log('receiver: ' + receiver);
        console.log('randomNumberHash: ' + randomNumberHash);
        // Submit cross chain transfer from ethereum to flow
        let ret = await ethereum.sendTransaction(NFTContract, 'crossChainTransfer', ethPrivateKey, [tokenId, receiver, randomNumberHash]);
        console.log('blockHash: ' + ret.blockHash);

    }catch(e){
        console.log(e);
    }
}else{
    console.log('Please input valid NFT id and random number hash value');
}