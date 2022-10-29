import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(): {Address: {String: String}} {
    let output: {Address: {String: String}} = {};

    for sendKey in CrossChain.registeredSendAccounts.keys {
        if let senderRef = SentMessageContract.getSenderRef(senderAddress: sendKey, link: CrossChain.registeredSendAccounts[sendKey]!) {
            output[sendKey] = senderRef.getCallbacks();
        }
    }

    return output;
}
