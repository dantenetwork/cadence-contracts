import SentMessageContract from "../../contracts/SentMessageContract.cdc"

transaction (id: UInt128) {

    prepare(acct: AuthAccount) {
        let sentVault = acct.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault)!;
        sentVault.clearSentMessage(id: id);
    }

    execute {
    }
}
