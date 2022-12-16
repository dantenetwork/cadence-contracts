import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import SQoSEngine from "../../contracts/SQoSEngine.cdc"

pub fun main(recver: Address): {String: {Address: SQoSEngine.HRRecord}} {
    let authAccount = getAuthAccount(recver);
    let recverRef = authAccount.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault)!;

    return recverRef.getHiddenRecords();
}

