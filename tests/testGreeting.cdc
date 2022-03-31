import CrossChain from 0xf8d6e0586b0a20c7;
import Greeting from 0xf8d6e0586b0a20c7;

transaction {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    let testContractName = "NearContractName";
    let testActionName = "NearActionName";
  
    // Send cross chain message
    log(Greeting.sendCrossChainMessage(toChain:"NEAR", contractName:testContractName , actionName:testActionName, data:"Hello ".concat(self.signer.address.toString())));
    log(Greeting.queryCrossChainSentMessage());

    // Received cross chain message
    log(Greeting.receiveCrossChainMessage(messageId:1, fromChain:"NEAR", contractName:testContractName , actionName:testActionName, data:"Hello ".concat(self.signer.address.toString())));
    log(Greeting.queryCrossChainSentMessage());
    
    // Query registers
    log(Greeting.register());
    log(CrossChain.queryRegisters());
  }
}