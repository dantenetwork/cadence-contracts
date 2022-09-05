import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(): {Address: [SentMessageContract.SentMessageCore]} {
    let output: {Address: [SentMessageContract.SentMessageCore]} = {};

    for sendKey in CrossChain.registeredSendAccounts.keys {
        if let senderRef = SentMessageContract.getSenderRef(senderAddress: sendKey, link: CrossChain.registeredSendAccounts[sendKey]!) {
            output[sendKey] = senderRef.getAllMessages();
        }
    }

    return output;
}
