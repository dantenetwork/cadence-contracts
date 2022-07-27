import MessageProtocol from "../contracts/MessageProtocol.cdc"

transaction {
    prepare(acct: AuthAccount) {

    }

    execute {
        let mi3 = MessageProtocol.MessageItem(name: "3", type: MessageProtocol.MsgType.cdcU64, value: 888 as UInt64);
    }
}
