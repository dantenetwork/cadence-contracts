import CrossChain from 0xf8d6e0586b0a20c7;
import Greeting from 0xf8d6e0586b0a20c7;

transaction {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    log(Greeting.sendCrossChainMessage(toChain:"NEAR", data:"Hello ".concat(self.signer.address.toString())));
    log(Greeting.queryCrossChainSentMessage());
    log(Greeting.register());
    log(CrossChain.queryRegisters());
  }
}