const fs = require('fs');
const Web3 = require('web3');
const ethereum = require('./ethereum.js');

const ethPrivateKey = fs.readFileSync(".secret").toString().trim();

// init ethereum contract
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');

const contractAddress = '0x6D23290E37963245Ac8Dd3e2D1461501F8E267E1';

let NFTRawData = fs.readFileSync('./build/contracts/NFT.json');
let NFTAbi = JSON.parse(NFTRawData).abi;

(async function () {
  console.log(new Date);

  let NFTContract = new web3.eth.Contract(NFTAbi, contractAddress);

  console.log('Mint NFT on rinkeby testnet');
  let ret = await ethereum.sendTransaction(NFTContract, 'mintTo', ethPrivateKey, ['0x3aE841B899Ae4652784EA734cc61F524c36325d1']);
  console.log(ret);
})();