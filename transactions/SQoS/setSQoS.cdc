import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc";
import MessageProtocol from "../../contracts/MessageProtocol.cdc";

transaction(){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        if let recvRef = self.signer.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault) {
            let sqos = MessageProtocol.SQoS();
            let u32bytes = UInt32(60).toBigEndianBytes();
            sqos.addItem(item: MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Challenge, value: u32bytes));
            recvRef.setSQoS(sqos: sqos);
        }
    }
}
