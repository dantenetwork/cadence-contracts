import StarLocker from "../contracts/StarLocker.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"
import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import MessageProtocol from "../../contracts/MessageProtocol.cdc"
import IdentityVerification from "../../contracts/IdentityVerification.cdc"
import SettlementContract from "../../contracts/Settlement.cdc";

/////////////////////////////////////////////////////////////////////////////////////////
// Query message to be sent
pub fun querySendMessageByID(messageID: UInt128): SentMessageContract.SentMessageCore? {
    for sendKey in CrossChain.registeredSendAccounts.keys {
        if let senderRef = SentMessageContract.getSenderRef(senderAddress: sendKey, link: CrossChain.registeredSendAccounts[sendKey]!) {
            if let messageInstance = senderRef.getMessageById(messageId: messageID) {
                return messageInstance;
            }
        }
    }

    return nil;
}

/////////////////////////////////////////////////////////////////////////////////////////
// Query next message ID to be submitted
pub struct NextMessageID {
    pub let id: UInt128;
    pub let recver: Address;

    init(id: UInt128, recver: Address) {
        self.id = id;
        self.recver = recver;
    }
}

// Query next message ID to be submitted
pub fun queryNextMessageIDtoSubmit(routerAddr: Address): {String: [NextMessageID]} {
    let nextIDs: {String: [NextMessageID]} = {};

    for recvKey in CrossChain.registeredRecvAccounts.keys {
        if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: recvKey, link: CrossChain.registeredRecvAccounts[recvKey]!) {
            // nextIDs[key] = recverRef.getNextMessageID(submitterAddr: routerAddr);
            let idsFromOneRecver = recverRef.getNextMessageID(submitterAddr: routerAddr);
            let nextIDsFromOneRecver: [NextMessageID] = [];
            for chainKey in idsFromOneRecver.keys {
                let nmid = NextMessageID(id: idsFromOneRecver[chainKey]!, recver: recvKey);
                if nextIDs.containsKey(chainKey) {
                    nextIDs[chainKey]!.append(nmid);
                } else {
                    nextIDs[chainKey] = [nmid];
                }
            }
        }
    }

    return nextIDs;
}

/////////////////////////////////////////////////////////////////////////////////////////
// create date for register router
pub fun createRouterData(pubAddr: Address): String {
    let n = IdentityVerification.getNonce(pubAddr: pubAddr);

    let originData: [UInt8] = pubAddr.toBytes().concat(n.toBigEndianBytes());

    return String.encodeHex(originData);
}

/////////////////////////////////////////////////////////////////////////////////////////
// construct date to be submitted onto Flow
pub struct createdData {
    pub let originMessage: ReceivedMessageContract.ReceivedMessageCore;
    pub let toBeSign: String;

    init(srcMessage: ReceivedMessageContract.ReceivedMessageCore, toBeSign: String) {
        self.originMessage = srcMessage;
        // self.rawData = rawData;
        self.toBeSign = toBeSign;
    }
}

pub fun generateSubmittion(
    id: UInt128, 
    fromChain: String,
    sender: [UInt8], 
    signer: [UInt8], 
    sqos: MessageProtocol.SQoS, 
    resourceAccount: Address, 
    link: String, 
    data: MessageProtocol.MessagePayload,
    session: MessageProtocol.Session, 
    msgSubmitter: Address
): createdData {

    let recvMsg = ReceivedMessageContract.ReceivedMessageCore(id: id, 
                                                                fromChain: fromChain, 
                                                                sender: sender, 
                                                                signer: signer,
                                                                sqos: sqos, 
                                                                resourceAccount: resourceAccount, 
                                                                link: link, 
                                                                data: data, 
                                                                session: session)

    // query signature nonce
    let n = IdentityVerification.getNonce(pubAddr: msgSubmitter);

    // Encode message bytes
    let originData: [UInt8] = msgSubmitter.toBytes().concat(n.toBigEndianBytes()).concat(recvMsg.getRecvMessageHash());

    // return createdDatarawData: receivedMessageCore.messageHash, toBeSign: String.encodeHex(originData));
    return createdData(srcMessage: recvMsg, toBeSign: String.encodeHex(originData));
}

/////////////////////////////////////////////////////////////////////////////////////////
// main process flow
pub fun main(address: Address) {

    // log(CrossChain.registeredSendAccounts);
    // log(CrossChain.queryRegisteredRecvAccount());

    let authAccount = getAuthAccount(address);

    let collectionRef = authAccount.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!;
    let minterRef = authAccount.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)!;
    let senderRef = authAccount.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault)!;
    let recverRef = authAccount.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault)!;

    let examplePublicRef = ExampleNFT.getExamplePubblic(addr: address);
    let collectionPublicRef = ExampleNFT.getCollectionPublic(addr: address);

    var loop = 0;
    while loop < 10 {
        minterRef.mintNFT(recipient: collectionPublicRef,
            name: "Example Series",
            description: "Hello Kitty",
            thumbnail: "ipfsurl",
            royalties: []);
        
        loop = loop + 1;
    }
    
    // log(examplePublicRef.getIDs());

    /////////////////////////////////////////////////////////////////////////////////////////
    // Test Send NFT out
    let nft2sendout <- collectionRef.withdraw(withdrawID: 3);
    // log(examplePublicRef.getIDs());

    let answer = "Hello Moon";
    let actionLink = "calleeVault";
    let hashValue = String.encodeHex(HashAlgorithm.KECCAK_256.hash(answer.utf8));

    StarLocker.sendoutNFT(transferToken: <-nft2sendout, 
                                toChain: "Nika",
                                contractName: address.toBytes(),
                                actionName: actionLink.utf8,
                                receiver: MessageProtocol.CDCAddress(addr: address.toBytes(), t: 4), 
                                hashValue: hashValue);

    // log(StarLocker.getLockedNFTs());
    
    let sentMsg = querySendMessageByID(messageID: 1)!;
    //log(SentMessageContract.QueryMessage(msgSender: address, link: "sentMessageVault"));
    //log(sentMsg);

    ////////////////////////////////////////////////////////////////////////////////////////
    // Test receive NFT and unlock
    let nextIDs = queryNextMessageIDtoSubmit(routerAddr: address);
    log(nextIDs);

    var nextID: UInt128 = 1;

    // Register router
    log(createRouterData(pubAddr: address));
    let routerRegisterSignature = "4f85f9bb8bfc466d13cd90368517f1e461bd05c1040c83f2b316a1a4714dab3a896a12e19d699fd7b28a14088f12f47f0a55d37a98962979e586ac52e97938c7";

    SettlementContract.registerRouter(pubAddr: address, 
                                            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, 
                                            signature: routerRegisterSignature.decodeHex(), 
                                            hashAlgorithm: HashAlgorithm.SHA3_256);

    // log(SettlementContract.getRegisteredRouters());

    // generate submittion
    let tobeSubmitted = generateSubmittion(
            id: nextID, 
            fromChain: sentMsg.toChain,
            sender: "Nika Chain User V".utf8, 
            signer: "Nika Chain User V".utf8, 
            sqos: sentMsg.sqos, 
            resourceAccount: address, 
            link: actionLink, 
            data: sentMsg.data,
            session: sentMsg.session, 
            msgSubmitter: address
    );

    //log(String.encodeHex(sentMsg.toBytes()));
    //log(String.encodeHex(tobeSubmitted.originMessage.toBytes()));
    log(tobeSubmitted.toBeSign);

    // signature of message to submit
    let submitSignature = "7b1dac2f4cad20bc4dc2829ef659079a674b47ca730071cea259d669ea44751fa9445c243a7c30b8347122dd4a7252296ca2a38674ebe286d7c44ceac366bd3e";

    if let recverRef = ReceivedMessageContract.getRecverRef(recverAddress: address, link: "receivedMessageVault") {
        recverRef.submitRecvMessage(
            recvMsg: tobeSubmitted.originMessage, 
            pubAddr: address, 
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, 
            signature: submitSignature.decodeHex()
        );
    } else {
        panic("Invalid `resourceAccount` or `link`!");
    }

    
}
 