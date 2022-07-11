import ReceivedMessageContract from 0xf8d6e0586b0a20c7;

transaction(
    message: String, 
    publicKey: String, 
    signature: String
) {
    let signer: AuthAccount;
    prepare(signer: AuthAccount){
      self.signer = signer;
    }
    
    execute {
      ReceivedMessageContract.verifySignature(message: message, publicKey: publicKey, signature: signature);
    }
}