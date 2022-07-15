import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from './ethereum.js';

const flowService = new FlowService();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');

// read private key
const ethPrivateKey = fs.readFileSync("./client/crosschain/.secret").toString().trim();

let NFTRawData = fs.readFileSync('./client/crosschain/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = '0x3dCf9DE8B5e07dB6ffd435911E085687B0A2dc99';

// TODO
// for debugging purpose, should be removed on the production environment
const anwser = '044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217';

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();

console.log('Initating cross chain sync service...');
console.log();

async function crossChainMint() {
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

  const message = sendMessages[sendMessages.length - 1];
  const tokenId = message.msgToSubmit.data.items[0].value;
  const tokenURL = message.msgToSubmit.data.items[1].value;
  const receiver = message.msgToSubmit.data.items[2].value;
  const hashValue = message.msgToSubmit.data.items[3].value;

  console.log('tokenId: ' + tokenId);
  console.log('tokenURL: ' + tokenURL);
  console.log('receiver: ' + receiver);
  console.log('hashValue: ' + hashValue);

  const isExists = await ethereum.contractCall(NFTContract, 'exists', [tokenId]);
  console.log(isExists);

  if(!isExists){
    let ret = await ethereum.sendTransaction(NFTContract, 'crossChainMint', ethPrivateKey, [tokenId, receiver, tokenURL, hashValue]);
    console.log(ret);

    setTimeout(() => {
      crossChainClaim(tokenId, anwser);
    }, 3000);
  }


//   if (rinkebyTotalSupply < flowLastId) {
//     console.log(new Date);
//     console.log('Rinkeby NFT total supply: ' + rinkebyTotalSupply);
//     console.log('Flow NFT total supply: ' + flowLastId);
//     let currentMessage = result[rinkebyTotalSupply];
//     console.log('Found new NFT :');
//     console.log(currentMessage);
//     console.log();
//     console.log();

//     console.log('Sync NFT to rinkeby testnet');
//     let ret = await ethereum.sendTransaction(NFTContract, currentMessage.content.actionName, ethPrivateKey, [currentMessage.content.data]);
//     console.log(ret);
//     await sync();
//   }else{
//     console.log('sleep 3 seconds.');
//     setTimeout(async () => {
//       await sync();
//     }, 3000);
//   }
};

async function crossChainClaim(tokenId, anwser){
  let ret = await ethereum.sendTransaction(NFTContract, 'crossChainClaim', ethPrivateKey, [tokenId, anwser]);
  console.log(ret);
}

await crossChainMint();
