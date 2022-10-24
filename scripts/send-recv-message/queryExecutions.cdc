import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(): {Address: [ReceivedMessageContract.ReceivedMessageCore]} {
    let output: {Address: [ReceivedMessageContract.ReceivedMessageCore]} = {};

    for recvKey in CrossChain.registeredRecvAccounts.keys {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recvKey, link: CrossChain.registeredRecvAccounts[recvKey]!) {
            output[recvKey] = recverRef.getExecutions();
        }
    }

    return output;
}
