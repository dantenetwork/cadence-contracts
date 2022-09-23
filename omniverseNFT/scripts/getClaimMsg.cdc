import StarLocker from "../contracts/StarLocker.cdc"
import MessageProtocol from "../../contracts/MessageProtocol.cdc"

pub fun main(): [MessageProtocol.MessagePayload]{
    return StarLocker.queryMessage();
}