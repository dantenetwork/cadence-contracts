import MessageProtocol from "../../contracts/MessageProtocol.cdc"

transaction (id: UInt128) {

    prepare(acct: AuthAccount) {
        MessageProtocol.changeMessageIDForce(id: id);
    }

    execute {
    }
}
