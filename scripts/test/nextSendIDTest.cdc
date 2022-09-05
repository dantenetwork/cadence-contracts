import MessageProtocol from "../../contracts/MessageProtocol.cdc";

pub fun main() {
    log(MessageProtocol.getNextMessageID());
    log(MessageProtocol.getNextMessageID());
    log(MessageProtocol.getNextMessageID());
    log(MessageProtocol.getNextMessageID());
}
