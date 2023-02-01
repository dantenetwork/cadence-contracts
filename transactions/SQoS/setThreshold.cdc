import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc";
import MessageProtocol from "../../contracts/MessageProtocol.cdc";

transaction(t: UInt32){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        if let recvRef = self.signer.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault) {
            let sqos = MessageProtocol.SQoS();
            let u32bytes = t.toBigEndianBytes();
            sqos.addItem(item: MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Threshold, value: u32bytes));
            recvRef.setSQoS(sqos: sqos);
        }
    }
}
