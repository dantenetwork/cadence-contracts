import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc";
import MessageProtocol from "../../contracts/MessageProtocol.cdc";

pub fun main(recver: Address): MessageProtocol.SQoS? {
    if let recvRef = ReceivedMessageContract.getRecverRef(recverAddress: recver, link: "receivedMessageVault") {
        return recvRef.getSQoS();
    }

    return nil;
}