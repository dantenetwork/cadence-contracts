import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from '../crosschain/ethereum.js';
import config from 'config';
import { send } from '@onflow/fcl';

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
// console.log(web3.eth.accounts.privateKeyToAccount(ethPrivateKey));

const nftContractAddress = config.get('ethereumContract');
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

// Mint NFT on Rinkeby
async function querySentMessageVault() {
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

    await crossChainMint(sendMessages);
};

let currentId = 0;
async function crossChainMint(sendMessages){
    if(sendMessages[currentId]){
        console.log('current time: ' + new Date());
        console.log(sendMessages[currentId]);
        // Get message info
        const message = sendMessages[currentId].msgToSubmit;
        const tokenId = message.data.items[0].value;
        const tokenURL = message.data.items[1].value;
        const receiver = message.data.items[2].value;
        const hashValue = message.data.items[3].value;

        console.log('tokenId: ' + tokenId);
        console.log('tokenURL: ' + tokenURL);
        console.log('receiver: ' + receiver);
        console.log('hashValue: ' + hashValue);

        let NFTContract = new web3.eth.Contract(NFTAbi, message.contractName);
        // make sure NTF is not exists
        const isExists = await ethereum.contractCall(NFTContract, 'exists', [tokenId]);
        console.log('Is NFT exists on Rinkeby? ' + isExists);

        // If hashValues exist, then NFT is already crossChainMint, but not claimed by the user yet
        const hashValues = await ethereum.contractCall(NFTContract, 'getHashValue', [tokenId]);
        console.log('hashValue of NTF on Rinkeby: ' + hashValues);

        if (!isExists && hashValues == "0x0000000000000000000000000000000000000000000000000000000000000000") {
            console.log('Submit cross chain mint to Rinkeby');
            let ret = await ethereum.sendTransaction(NFTContract, message.actionName, ethPrivateKey, [tokenId, receiver, tokenURL, hashValue]);
            console.log('blockHash: ' + ret.blockHash);
        }
        currentId++;
        await crossChainMint(sendMessages);
    }else{
        console.log('sleep 3 seconds.');
        setTimeout(async () => {
            await querySentMessageVault();
        }, 3000);
    }

}

await querySentMessageVault();