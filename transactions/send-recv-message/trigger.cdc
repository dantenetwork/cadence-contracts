import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

transaction(recver: Address, msgID: UInt128, fromChain: String, recverLink: String){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recver, link: recverLink) {
            if recverRef.isExecutable() {
                recverRef.trigger(msgID: msgID, fromChain: fromChain);
            }
        }
    }
}
