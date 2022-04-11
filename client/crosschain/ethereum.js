import Web3 from 'web3';
const web3 = new Web3('https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161');
web3.eth.handleRevert = true;

const chainId = 4;

class Ethereum {
  // 通过私钥签名交易
  sendTransaction = async (
    targetContract, methodName, accountPrivateKey, params) => {
    try {
      const account =
        web3.eth.accounts.privateKeyToAccount(accountPrivateKey)
          .address;  // 私钥导出公钥
      const to = targetContract.options.address;
      const nonce = web3.utils.numberToHex(
        await web3.eth.getTransactionCount(account));  // 获取生成 nonce
      const data = targetContract.methods[methodName]
        .apply(targetContract.methods, params)
        .encodeABI();  // encode ABI
      const gas = web3.utils.numberToHex(
        parseInt((await web3.eth.getBlock('latest')).gasLimit - 1));
      let gasPrice = await web3.eth.getGasPrice();
      gasPrice = 20000000000;

      // 准备交易数据
      const tx = { account, to, chainId, data, nonce, gasPrice, gas: 1000000 };
      console.log(tx);

      // 签名交易
      let signTx =
        await web3.eth.accounts.signTransaction(tx, accountPrivateKey);
      let ret = await web3.eth.sendSignedTransaction(signTx.rawTransaction);
      console.log('gasUsed: ' + methodName + ' ' + ret.gasUsed);
      return ret;
    } catch (e) {
      console.error(e);
    }
  }
  // query info from blockchain node
  contractCall = async (targetContract, method, params) => {
    let methodObj =
      targetContract.methods[method].apply(targetContract.methods, params);
    let ret = await methodObj.call({});
    return ret;
  }
}

export default Ethereum;