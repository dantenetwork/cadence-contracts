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

    log("Initiallizing...");
    let authAccount = getAuthAccount(address);

    let collectionRef = authAccount.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!;
    let minterRef = authAccount.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)!;
    let senderRef = authAccount.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault)!;
    let recverRef = authAccount.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault)!;

    let examplePublicRef = ExampleNFT.getExamplePubblic(addr: address);
    let collectionPublicRef = ExampleNFT.getCollectionPublic(addr: address);

    log("Mint 10 NFTs to operator account: ".concat(address.toString()));
    log("----------------------------------------------------------------")

    var loop = 0;
    while loop < 10 {
        minterRef.mintNFT(recipient: collectionPublicRef,
            description: "Hello Kitty",
            thumbnail: "ipfsurl",
            royalties: []);
        
        loop = loop + 1;
    }
    
    log("NFT: ");
    log(examplePublicRef.getIDs());
    log(" are minted to account: ".concat(address.toString()));
    log("----------------------------------------------------------------")
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

    log("After sending out the NFT of id 3, the operator account has NFTs: ")
    log(examplePublicRef.getIDs());

    log("And the locked NFTs are: ")
    log(StarLocker.getLockedNFTs());
    log("----------------------------------------------------------------")
    
    let sentMsg = querySendMessageByID(messageID: 1)!;
    //log(SentMessageContract.QueryMessage(msgSender: address, link: "sentMessageVault"));
    //log(sentMsg);

    ////////////////////////////////////////////////////////////////////////////////////////
    // Test receive NFT and unlock
    var nextIDs = queryNextMessageIDtoSubmit(routerAddr: address);
    // log(nextIDs);

    var nextID: UInt128 = 1;

    // Register router
    // log(createRouterData(pubAddr: address));
    let routerRegisterSignature = "4f85f9bb8bfc466d13cd90368517f1e461bd05c1040c83f2b316a1a4714dab3a896a12e19d699fd7b28a14088f12f47f0a55d37a98962979e586ac52e97938c7";

    SettlementContract.registerRouter(pubAddr: address, 
                                            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, 
                                            signature: routerRegisterSignature.decodeHex(), 
                                            hashAlgorithm: HashAlgorithm.SHA3_256);

    log("Register a router to prepare receiving messages, now we have routers: ")
    log(SettlementContract.getRegisteredRouters());
    log("----------------------------------------------------------------")
    // generate submittion. Use the content of `sentMsg` to simulate the receiving messages
    // toChain and fromChain are exchanged
    log("Simulate receiving messages from a chain named `Nika` and submitting the message on to Flow...");
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
    // log(tobeSubmitted.toBeSign);


    // signature of message to submit. The following signature is signed by off-chain js
    let submitSignature = "d04d5ba046febe22cb8eecec172e3dca14762eda2f25f915f29f79655279b45daeb64d4f6a1012f2822996e4ff028705d2c09c36237c4dd190c1e66187270eac";

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

    //nextIDs = queryNextMessageIDtoSubmit(routerAddr: address);
    //log(nextIDs);

    log("This message means there is an NFT transferred from outside, and an NFT locked and sent out before could be released if some input a correct hash-locked answer: ")
    log(StarLocker.queryMessage());
    log("----------------------------------------------------------------")

    log("Before claiming out, the NFTs the operator has are: ")
    log(examplePublicRef.getIDs());
    StarLocker.claimNFT(domain: ExampleNFT.domainName, id: 3, answer: answer);
    log("After claiming out, the NFTs the operator has are: ")
    log(examplePublicRef.getIDs());
}
