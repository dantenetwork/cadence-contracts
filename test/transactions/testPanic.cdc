import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"

transaction(){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        ReceivedMessageContract.testPanic();
    }
}
