import MessageProtocol from "../contracts/MessageProtocol.cdc"

pub fun getString(): AnyStruct {
    let mp = MessageProtocol.MessagePayload();
    let mi = MessageProtocol.createMessageItem(name: "1", type: MessageProtocol.MsgType.cdcString, value: "in function");

    mp.addItem(item: mi!);

    return mp.items[0].value
    // return mp.items[0].value as? String
}

pub fun main(): [UInt8] {
    let mp = MessageProtocol.MessagePayload();

    let nums: Int32 = [99, 88, 77];
    let miNumber = MessageProtocol.createMessageItem(name: "1", type: MessageProtocol.MsgType.cdcVecI32, value: nums);
    mp.addItem(item: miNumber!);

    let miStr = MessageProtocol.createMessageItem(name: "2", type: MessageProtocol.MsgType.cdcString, value: "Hello Nika");
    mp.addItem(item: miStr);

    return mp.toBytes();
}
