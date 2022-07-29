import Locker from 0xf8d6e0586b0a20c7;

transaction(id: UInt64, 
            answer: String
){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer;
    }

    execute {
        Locker.claimNFT(id: id, answer: answer);
    }
}