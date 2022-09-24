import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(chain: String, messageID: UInt128): SentMessageContract.SentMessageCore? {
    for sendKey in CrossChain.registeredSendAccounts.keys {
        if let senderRef = SentMessageContract.getSenderRef(senderAddress: sendKey, link: CrossChain.registeredSendAccounts[sendKey]!) {
            if let messageInstance = senderRef.getMessageById(chain: chain, messageId: messageID) {
                return messageInstance;
            }
        }
    }

    return nil;
}
 