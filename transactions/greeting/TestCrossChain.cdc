import CrossChain from 0xf8d6e0586b0a20c7;
import Greeting from 0xf8d6e0586b0a20c7;

transaction {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    let testContractName = "EthereumContractName";
    let testActionName = "EthereumActionName";
  
    // Send cross chain message
    log(Greeting.sendCrossChainMessage(toChain:"Ethereum", contractName:testContractName , actionName:testActionName, data:"Hello ".concat(self.signer.address.toString())));

    // Received cross chain message
    log(Greeting.receiveCrossChainMessage(messageId:0, fromChain:"Ethereum", contractName:testContractName , actionName:testActionName, data:"Hello ".concat(self.signer.address.toString())));
    
    // Query registers
    log(Greeting.register());
  }
}