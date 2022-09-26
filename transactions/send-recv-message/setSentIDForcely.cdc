import MessageRecorder from "../../contracts/MessageRecorder.cdc"

transaction (chain: String, id: UInt128) {

    prepare(acct: AuthAccount) {
        MessageRecorder.changeMessageIDForce(chain: chain, id: id);
    }

    execute {
    }
}
