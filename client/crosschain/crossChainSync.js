import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from './ethereum.js';

const flowService = new FlowService();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
// TODO add private key
const ethPrivateKey = '';

let NFTRawData = fs.readFileSync('./client/crosschain/KingHonorNFTView.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

let currentId = 1;

async function sync() {
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

  const lastId = result.length;
  if (currentId < lastId) {
    let currentMessage = result[currentId];
    console.log('Found new NFT :');
    console.log(currentMessage);
    console.log();
    console.log();

    let NFTContract = new web3.eth.Contract(NFTAbi, currentMessage.content.contractName);
    const ethereum = new Ethereum();

    console.log('Sync NFT to rinkeby testnet');
    let ret = await ethereum.sendTransaction(NFTContract, currentMessage.content.actionName, ethPrivateKey, [currentMessage.content.data]);
    console.log(ret);
    currentId = currentId + 1;
  }
  console.log('sleep 3 seconds.');
  setTimeout(async () => {
    await sync();
  }, 3000);
};

await sync();

