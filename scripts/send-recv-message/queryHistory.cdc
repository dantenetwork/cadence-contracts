import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(): {Address: {String: [ReceivedMessageContract.ReceivedMessageCache]}} {
    let output: {Address: {String: [ReceivedMessageContract.ReceivedMessageCache]}} = {};

    for recvKey in CrossChain.registeredRecvAccounts.keys {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recvKey, link: CrossChain.registeredRecvAccounts[recvKey]!) {
            output[recvKey] = recverRef.getHistory();
        }
    }

    return output;
}
