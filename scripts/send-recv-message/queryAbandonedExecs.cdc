import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(): {Address: [ReceivedMessageContract.ExecData]} {
    let output: {Address: [ReceivedMessageContract.ExecData]} = {};

    for recvKey in CrossChain.registeredRecvAccounts.keys {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recvKey, link: CrossChain.registeredRecvAccounts[recvKey]!) {
            output[recvKey] = recverRef.getAbandonedExecs();
        }
    }

    return output;
}
