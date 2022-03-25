import Greeting from 0x03
import CrossChain from 0x02

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