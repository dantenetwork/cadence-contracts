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

async function clearDQ() {
    console.log('Clear Data Queue on Rinkeby');
    let ret = await ethereum.sendTransaction(NFTContract, 'clearMsg', ethPrivateKey, []);
    console.log('blockHash: ' + ret.blockHash);
}

await clearDQ();