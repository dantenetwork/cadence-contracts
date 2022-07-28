import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';

let signer = config.get('emulator');

if (config.get('network') == 'testnet') {
    signer = config.get('testnet');
}
const flowService = new FlowService(signer.address, signer.privateKey, signer.keyId);

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();
const nftContractAddress = config.get('ethereumContract');
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

// Mint NFT on Rinkeby
async function crossChainMint(messageId) {
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

    // console.log(sendMessages);

    if(sendMessages.length < messageId){
        console.log('messageId ' + messageId + ' is not found');
        return;
    }
    // Get message info
    const message = sendMessages[messageId - 1].msgToSubmit;
    const tokenId = message.data.items[0].value;
    const tokenURL = message.data.items[1].value;
    const receiver = message.data.items[2].value;
    const hashValue = message.data.items[3].value;

    console.log('tokenId: ' + tokenId);
    console.log('tokenURL: ' + tokenURL);
    console.log('receiver: ' + receiver);
    console.log('hashValue: ' + hashValue);

    let NFTContract = new web3.eth.Contract(NFTAbi, message.contractName);
    const isExists = await ethereum.contractCall(NFTContract, 'exists', [tokenId]);
    console.log('isExists: ' + isExists);

    if (!isExists) {
        console.log('Submit cross chain mint to ethereum');
        let ret = await ethereum.sendTransaction(NFTContract, message.actionName, ethPrivateKey, [tokenId, receiver, tokenURL, hashValue]);
        console.log('blockHash: ' + ret.blockHash);
    }

};

const messageId = process.argv[2];
console.log('messageId: ' + messageId);

if(messageId && messageId > 0){
    await crossChainMint(messageId);
}else{
    console.log('Please input valid message id');
}