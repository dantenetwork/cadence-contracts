import NFTCrossChain from 0xf8d6e0586b0a20c7;

transaction(){
  let signer: AuthAccount;
  prepare(signer: AuthAccount){
    self.signer = signer;
  }

  execute {
    NFTCrossChain.resetSentMessageVault();
  }
}