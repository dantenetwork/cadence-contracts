import ReceivedMessageContract from "../contracts/ReceivedMessageContract.cdc"
import MessageProtocol from "../contracts/MessageProtocol.cdc"
import IdentityVerification from "../contracts/IdentityVerification.cdc"

pub struct createdData {
    pub let rawData: String;
    pub let toBeSign: String;

    init(rawData: String, toBeSign: String) {
        self.rawData = rawData;
        self.toBeSign = toBeSign;
    }
}

pub fun main(): createdData {
    let recvData = ReceivedMessageContract.ReceivedMessageCore(id: 1, 
                                                                fromChain: "1",
                                                                sender: "2", 
                                                                sqos: MessageProtocol.SQoS(), 
                                                                resourceAccount: 0x01, 
                                                                link: "3", 
                                                                data: MessageProtocol.MessagePayload(),
                                                                session: MessageProtocol.Session(oId: 123, oType: 1, oCallback: "4", oc: [1], oa: [2]));

    let addr: Address = 0xf8d6e0586b0a20c7;
    let n = IdentityVerification.getNonce(pubAddr: addr);

    let originData: [UInt8] = addr.toBytes().concat(n.toBigEndianBytes()).concat(recvData.getRecvMessageHash());

    return createdData(rawData: recvData.messageHash, toBeSign: String.encodeHex(originData));
    // return createdData(rawData: recvData.getRecvMessageHash(), toBeSign: originData);
}
