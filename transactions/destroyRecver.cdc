import ReceivedMessageContract from "../contracts/ReceivedMessageContract.cdc"

transaction () {

    prepare(acct: AuthAccount) {
        if let recverValt <- acct.load<@ReceivedMessageContract.ReceivedMessageVault>(from: /storage/myRecver) {
            destroy recverValt;
        }
    }

    execute {
        
    }
}