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

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

const util = new Util();

console.log('Initating cross chain sync service...');
console.log();

async function crossChainMint() {
    // Query last NFT id
    var totalSupply = await util.queryTotalSupply();
    const tokenId = totalSupply;

    // Query cross chain message from flow to ethereum
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            './transactions/nft/QuerySentMessage.cdc'
        ),
        'utf8'
    );

    const sendMessages = await flowService.executeScript({
        script: script,
        args: []
    });

    // Get message info
    const message = sendMessages[tokenId - 1];
    const tokenURL = message.msgToSubmit.data.items[1].value;
    const receiver = message.msgToSubmit.data.items[2].value;
    const hashValue = message.msgToSubmit.data.items[3].value;

    console.log('tokenId: ' + tokenId);
    console.log('tokenURL: ' + tokenURL);
    console.log('receiver: ' + receiver);
    console.log('hashValue: ' + hashValue);

    const isExists = await ethereum.contractCall(NFTContract, 'exists', [tokenId]);
    console.log('isExists: ' + isExists);

    if (!isExists) {
        console.log('Submit cross chain mint to ethereum');
        let ret = await ethereum.sendTransaction(NFTContract, 'crossChainMint', ethPrivateKey, [tokenId, receiver, tokenURL, hashValue]);
        console.log('blockHash: ' + ret.blockHash);

        setTimeout(async () => {
            await crossChainClaim(tokenId, randomNumber);
        }, 3000);
    }

};

async function crossChainClaim(tokenId, randomNumber) {
    console.log();
    console.log('Submit cross chain claim to ethereum');
    console.log('tokenId: ' + tokenId);
    console.log('randomNumber: ' + randomNumber);
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainClaim', ethPrivateKey, [tokenId, randomNumber]);
    console.log('blockHash: ' + ret.blockHash);

    setTimeout(async () => {
        // Query NFT owner
        console.log();
        console.log('Query NFT info on ethereum');
        const ownerOf = await ethereum.contractCall(NFTContract, 'ownerOf', [tokenId]);
        console.log('ownerOf: ' + ownerOf);

        const tokenURI = await ethereum.contractCall(NFTContract, 'tokenURI', [tokenId]);
        console.log('ownerOf: ' + tokenURI);
    }, 3000);

}

await crossChainMint();
