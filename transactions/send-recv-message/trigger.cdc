import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

transaction(){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        for recvKey in CrossChain.registeredRecvAccounts.keys {
            if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recvKey, link: CrossChain.registeredRecvAccounts[recvKey]!) {
                if recverRef.isExecutable() {
                    recverRef.trigger();
                    break;
                }
            }
        }
    }
}
