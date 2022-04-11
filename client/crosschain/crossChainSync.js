import fs from 'fs';
import path from 'path';
import FlowService from '../flow.mjs';
import config from 'config';

import Web3 from 'web3';
import Ethereum from './ethereum.js';

// init flow service
const address = config.get('address');
const privateKey = config.get('privateKey');
const keyId = config.get('keyId');

const flowService = new FlowService(
  address,
  privateKey,
  keyId
);

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
const ethPrivateKey = '48beef7bacb7a61d88c8f6ff44c87a007a85e8178bfe96966962390a9f43c80b';
const NFTContractAddress = '0xe75507f791862d619be19F57384A7625328Bd411';
let NFTRawData = fs.readFileSync('./client/crosschain/KingHonorNFTView.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

let NFTContract = new web3.eth.Contract(NFTAbi, NFTContractAddress);
const ethereum = new Ethereum();


const lastId = -1;

async function sync() {
  const script = fs.readFileSync(
    path.join(
      process.cwd(),
      './transactions/nft/QueryCrossChainMessage.cdc'
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
    console.log('Sync NFT meta data to ethereum testnet');
    await ethereum.sendTransaction(NFTContract, 'mintTo', ethPrivateKey, ['0xed911ca21fdba9db5f3b61b014b96a9fab665ff9']);
  } else {
    console.log('sleep 3 seconds.');
    setTimeout(async () => {
      await sync();
    }, 3000);
  }
};

await sync();

