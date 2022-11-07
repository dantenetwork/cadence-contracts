import SentMessageContract from "../../contracts/SentMessageContract.cdc"

pub fun main(): {String: SentMessageContract.CallbackRecord} {
    return SentMessageContract.getCallbacks();
}
