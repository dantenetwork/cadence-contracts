// import MessageProtocol from "../contracts/MessageProtocol.cdc"
// import MessageProtocol from 0xf8d6e0586b0a20c7;
import MessageProtocol from 0xProfile;

pub fun main(): Address {

    let mp = MessageProtocol.MessagePayload();

    let addr = MessageProtocol.CDCAddress(addr: [1, 2, 3, 4], t: 4);

    let mi = MessageProtocol.createMessageItem(name: "1", type: MessageProtocol.MsgType.cdcAddress, value: addr)!;
    mp.addItem(item: mi);

    return (mp.getItem(name: "1")!.value as! MessageProtocol.CDCAddress).getFlowAddress()!;

    // let s = "helloworld";

    // return s.slice(from: 3, upTo: 6);
}
