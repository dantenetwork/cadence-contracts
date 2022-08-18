import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main(routerAddr: Address): {String: {Address: UInt128}} {
    let nextIDs: {String: {Address: UInt128}} = {};

    for key in CrossChain.registeredRecvAccounts.keys {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: key, link: CrossChain.registeredRecvAccounts[key]!) {
            nextIDs[key] = recverRef.getNextMessageID(submitterAddr: routerAddr);
        }
    }

    return nextIDs;
}

