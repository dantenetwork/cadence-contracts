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

let NFTRawData = fs.readFileSync('./client/crosschain/KingHonorNFTView.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

const nftContractAddress = '0x263037FdFa433828fCBF97B87200A0E0b8d68C5f';

// let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
let NFTContract = new web3.eth.Contract(NFTAbi, nftContractAddress);
const ethereum = new Ethereum();


let rinkebyTotalSupply=0;
console.log('Initating cross chain sync service...');

async function sync() {
  rinkebyTotalSupply = await ethereum.contractCall(NFTContract,'totalSupply');
  rinkebyTotalSupply++;

  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QuerySentMessage.cdc'
    ),
    'utf8'
  );

  const result = await flowService.executeScript({
    script: script,
    args: []
  });

  const flowLastId = result.length;
  if (rinkebyTotalSupply < flowLastId) {
    console.log(new Date);
    console.log('Rinkeby NFT total supply: ' + rinkebyTotalSupply);
    console.log('Flow NFT total supply: ' + flowLastId);
    let currentMessage = result[rinkebyTotalSupply];
    console.log('Found new NFT :');
    console.log(currentMessage);
    console.log();
    console.log();

    console.log('Sync NFT to rinkeby testnet');
    let ret = await ethereum.sendTransaction(NFTContract, currentMessage.content.actionName, ethPrivateKey, [currentMessage.content.data]);
    console.log(ret);
    await sync();
  }else{
    console.log('sleep 3 seconds.');
    setTimeout(async () => {
      await sync();
    }, 3000);
  }
};

await sync();
