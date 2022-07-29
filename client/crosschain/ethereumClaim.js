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

async function crossChainClaim(tokenId, randomNumber) {
    console.log('Submit cross chain claim to Rinkeby');
    console.log('randomNumber: ' + randomNumber);
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainClaim', ethPrivateKey, [tokenId, randomNumber]);
    console.log('blockHash: ' + ret.blockHash);

    setTimeout(async () => {
        // Query NFT owner
        console.log();
        console.log('Query NFT info on Rinkeby');
        const ownerOf = await ethereum.contractCall(NFTContract, 'ownerOf', [tokenId]);
        console.log('ownerOf: ' + ownerOf);

        const tokenURI = await ethereum.contractCall(NFTContract, 'tokenURI', [tokenId]);
        console.log('ownerOf: ' + tokenURI);
    }, 3000);

}

// Get input params
const tokenId = process.argv[2];
const randomNumber = process.argv[3];

console.log('tokenId: ' + tokenId);
if(tokenId > 0 && randomNumber != ''){
    await crossChainClaim(tokenId, randomNumber);
}else{
    console.log('Please input valid NFT id & random number');
}