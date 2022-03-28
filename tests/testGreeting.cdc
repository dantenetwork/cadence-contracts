import CrossChain from 0xf8d6e0586b0a20c7;
import Greeting from 0xf8d6e0586b0a20c7;

transaction {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    log(Greeting.addCrossChainMessage(toChain:"NEAR", data:"Hello ".concat(self.signer.address.toString())));
    log(Greeting.queryCrossChainMessage());
    log(Greeting.register());
    log(CrossChain.queryRegisters());
  }
}