import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import Web3 from 'web3';
import Ethereum from './ethereum.js';

const flowService = new FlowService();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
const ethPrivateKey = '48beef7bacb7a61d88c8f6ff44c87a007a85e8178bfe96966962390a9f43c80b';
let NFTRawData = fs.readFileSync('./client/crosschain/KingHonorNFTView.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

let lastId = -1;

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

  const currentId = result.length - 1;
  if (currentId > lastId) {
    console.log('Found new NFT meta data:');
    console.log(result[currentId]);
    console.log();
    console.log();

    let NFTContract = new web3.eth.Contract(NFTAbi, result[currentId].content.contractName);
    const ethereum = new Ethereum();

    console.log('Sync NFT meta data to ethereum testnet');
    await ethereum.sendTransaction(NFTContract, result[currentId].content.actionName, ethPrivateKey, [result[currentId].content.data]);
  }
  lastId = currentId;
  console.log('sleep 3 seconds.');
  setTimeout(async () => {
    await sync();
  }, 3000);
};

await sync();

