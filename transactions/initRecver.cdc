import ReceivedMessageContract from "../contracts/ReceivedMessageContract.cdc"

transaction () {

    prepare(acct: AuthAccount) {
        let recvVault <- ReceivedMessageContract.createReceivedMessageVault();

        acct.save(<- recvVault, to: /storage/myRecver);
        acct.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/myRecver, target: /storage/myRecver);
    }

    execute {
        
    }
}