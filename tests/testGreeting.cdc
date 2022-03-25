import Greeting from 0xf8d6e0586b0a20c7
import CrossChain from 0xf8d6e0586b0a20c7

transaction {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    log(Greeting.sendMessage(messageInfo:"Hello ".concat(self.signer.address.toString())));
    log(CrossChain.queryMessageByIndex(index:0));
    log(CrossChain.queryLastMessage());    
    log(CrossChain.queryMessageCount());
  }
}