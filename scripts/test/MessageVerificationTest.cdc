import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc";
import SettlementContract from "../../contracts/Settlement.cdc";
import MessageProtocol from "../../contracts/MessageProtocol.cdc"

///////////////////////////////////////////////////////////////////////
// Randomly register routers
pub fun registerRouter(addrCount: UInt64) {
    var addr: UInt64 = 0x01;
        let routers: [Address] = [];
        while addr < (addrCount + 1) {
            routers.append(Address(addr));
            addr = addr + 1;
        }

    SettlementContract.testRegisterRouters(routers: routers);
}

pub fun printRouters(routers: [SettlementContract.Validator]): {Address: UFix64} {
    let output: {Address: UFix64} = {};

    for router in routers {
        output[router.address] = router.crd;
    }

    return output;
}

///////////////////////////////////////////////////////////////////////
// simulate message set `ReceivedMessageCache`
pub fun simulateMessageSet(routers: [SettlementContract.Validator]): ReceivedMessageContract.ReceivedMessageCache {
    let recvedCache = ReceivedMessageContract.ReceivedMessageCache(id : 1);
    for router in routers {
        let messageCopy = ReceivedMessageContract.ReceivedMessageCore(id: 1, 
                                                                fromChain: "", 
                                                                sender: [], 
                                                                signer: [],
                                                                sqos: MessageProtocol.SQoS(), 
                                                                resourceAccount: 0x01, 
                                                                link: "", 
                                                                data: MessageProtocol.MessagePayload(), 
                                                                // create a random `Session.id` to simulation 3 different contents of submittion message
                                                                session: MessageProtocol.Session(oId: UInt128(unsafeRandom() % 3), 
                                                                                                    oType: 1, 
                                                                                                    oCallback: nil, 
                                                                                                    oc: nil, 
                                                                                                    oa: nil));
        recvedCache.insert(receivedMessageCore: messageCopy, pubAddr: router.address);
    }

    return recvedCache;
}

pub fun main() {
    ///////////////////////////////////////////////////
    // Randomly register routers
    log("Initiallizing...");
    log("Register 10 test routers with random credibility: ");
    registerRouter(addrCount: 10);
    let routers = SettlementContract.getRegisteredRouters();
    log(printRouters(routers: routers));
    log("----------------------------------------------------------------")

    ///////////////////////////////////////////////////
    // Construct a simulated message copies set `ReceivedMessageCache`
    log("simulate 10 routers submitting 3 different message copies..."); 
    let receivedCache = simulateMessageSet(routers: routers);
    for ele in receivedCache.msgInstance.values {
        log("Message copy hash: ".concat(ele.messageInfo.messageHash));
        log("Submitters: ");
        log(ele.submitters);
    }
    log("----------------------------------------------------------------")

    ///////////////////////////////////////////////////
    // make verification
    let recver <- ReceivedMessageContract.createReceivedMessageVault();
    log("Verification result: ");
    if let verifiedMessage = recver.messageVerify(messageCache: receivedCache){
        log("Success: ".concat(verifiedMessage.messageHash));
    } else {
        log("Verification failed as none of the message copy get enough credibility!");
    }
    destroy recver;
}
