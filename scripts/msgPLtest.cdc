import MessageProtocol from "../contracts/MessageProtocol.cdc"

pub fun getString(): AnyStruct {
    let mp = MessageProtocol.MessagePayload();
    let mi = MessageProtocol.createMessageItem(name: "1", type: MessageProtocol.MsgType.cdcString, value: "in function");

    mp.addItem(item: mi!);

    return mp.items[0].value
    // return mp.items[0].value as? String
}

pub fun main(): [AnyStruct?] {
    let vout: [AnyStruct?] = [];

    let mp = MessageProtocol.MessagePayload();

    let mi = MessageProtocol.createMessageItem(name: "1", type: MessageProtocol.MsgType.cdcString, value: "Hello");
    mp.addItem(item: mi!);

    let mi2 = MessageProtocol.createMessageItem(name: "2", type: MessageProtocol.MsgType.cdcU64, value: 999 as UInt64);
    mp.addItem(item: mi2!);

    var item = mp.getItem(name: "1")!;
    vout.append(item.value);

    vout.append(mp.items[0].value as? String);

    item = mp.getItem(name: "2")!;
    vout.append(item.value);

    let mi3 = MessageProtocol.MessageItem(name: "3", type: MessageProtocol.MsgType.cdcU64, value: 888 as UInt64)

    vout.append(getString());

    return vout;
}
