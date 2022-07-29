import fs from 'fs';
import Web3 from 'web3';
import Ethereum from './ethereum.js';
import config from 'config';
// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
// read private key
const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();

let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;
const nftContractAddress = config.get('ethereumContract');
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

async function crossChainClaim(tokenId) {
    // Query NFT owner
    console.log('Query NFT info on Rinkeby');
    const ownerOf = await ethereum.contractCall(NFTContract, 'ownerOf', [tokenId]);
    console.log('ownerOf: ' + ownerOf);

    const tokenURI = await ethereum.contractCall(NFTContract, 'tokenURI', [tokenId]);
    console.log('ownerOf: ' + tokenURI);

    let ret = await ethereum.sendTransaction(NFTContract, 'burn', ethPrivateKey, [tokenId]);
    console.log('blockHash: ' + ret.blockHash);
}

// Get input params
const tokenId = process.argv[2];

console.log('tokenId: ' + tokenId);
if(tokenId > 0){
    await crossChainClaim(tokenId);
}else{
    console.log('Please input valid NFT id');
}