const Web3 = require('web3');
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
web3.eth.handleRevert = true;

const chainId = 4;

module.exports = {
  // sign transaction by private key
  sendTransaction: async function async(
    targetContract, methodName, accountPrivateKey, params) {
    try {
      const account =
        web3.eth.accounts.privateKeyToAccount(accountPrivateKey)
          .address;
      const to = targetContract.options.address;
      const nonce = web3.utils.numberToHex(
        await web3.eth.getTransactionCount(account));  // get nonce
      const data = targetContract.methods[methodName]
        .apply(targetContract.methods, params)
        .encodeABI();  // encode ABI
      const gas = web3.utils.numberToHex(
        parseInt((await web3.eth.getBlock('latest')).gasLimit - 1));
      let gasPrice = await web3.eth.getGasPrice();
      gasPrice = 20000000000;

      // prepare transaction data
      const tx = { account, to, chainId, data, nonce, gasPrice, gas: 1000000 };
      console.log(tx);

      // sign transaction
      let signTx =
        await web3.eth.accounts.signTransaction(tx, accountPrivateKey);
      let ret = await web3.eth.sendSignedTransaction(signTx.rawTransaction);
      console.log('gasUsed: ' + methodName + ' ' + ret.gasUsed);
      return ret;
    } catch (e) {
      console.error(e);
    }
  },
  // query info from blockchain node
  contractCall: async function (targetContract, method, params) {
    let methodObj =
      targetContract.methods[method].apply(targetContract.methods, params);
    let ret = await methodObj.call({});
    return ret;
  }
}