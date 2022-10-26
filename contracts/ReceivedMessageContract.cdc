import MessageProtocol from "./MessageProtocol.cdc";
import IdentityVerification from "./IdentityVerification.cdc";
import SettlementContract from "./Settlement.cdc";
import ContextKeeper from "./ContextKeeper.cdc";

pub contract ReceivedMessageContract{
    
    // Interface is used for access control.
    pub resource interface ReceivedMessageInterface{
        pub fun getCompleteID(): {String: UInt128};

        // Get the next valid message id to be submitted from source chains by off-chain routers 
        pub fun getNextMessageID(submitterAddr: Address): {String: UInt128};

        pub fun submitRecvMessage(recvMsg: ReceivedMessageCore, 
                                  pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]);

        pub fun submitAbandoned(msgID: UInt128, fromChain: String,  
                                pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]);

        pub fun isOnline(): Bool;

        // Execution
        pub fun trigger();
        pub fun isExecutable(): Bool;
        pub fun getExecutions(): [ReceivedMessageCore];

        // history
        pub fun getHistory(): {String: [ReceivedMessageCache]};
    }
    
    pub resource interface Callee {
        pub fun callMe(data: MessageProtocol.MessagePayload);
    }
    
    pub struct Content {
        // `accountAddress` needs to be converted from bytes into Address in off-chain router
        pub let accountAddress: Address;
        // `link` needs to be converted from bytes into Address in off-chain router
        pub let link: String;
        pub let data: MessageProtocol.MessagePayload;

        init(resourceAccount: Address, link: String, data: MessageProtocol.MessagePayload) {
            self.accountAddress = resourceAccount;
            self.link = link;
            self.data = data;
        }

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];

            dataBytes = dataBytes.concat(self.accountAddress.toBytes());
            dataBytes = dataBytes.concat(self.link.utf8);
            dataBytes = dataBytes.concat(self.data.toBytes());

            return dataBytes;
        }
    }

    // Define message core
    pub struct ReceivedMessageCore{
        pub let id: UInt128; // message id
        pub let fromChain: String; // FLOW, source chain name
        pub let toChain: String; // destination chain name

        pub let sender: [UInt8]; // sender of cross chain message
        pub let signer: [UInt8];
        pub let sqos: MessageProtocol.SQoS;
        pub let content: Content; // message content
        pub let session: MessageProtocol.Session;
        pub var messageHash: String; // message hash value

        init(id: UInt128, fromChain: String, sender: [UInt8], signer: [UInt8], sqos: MessageProtocol.SQoS, 
            resourceAccount: Address, link: String, data: MessageProtocol.MessagePayload,
            session: MessageProtocol.Session){
            self.id = id;
            self.fromChain = fromChain;
            self.toChain = "FLOWTEST";
            self.sender = sender;
            self.signer = signer;
            self.sqos = sqos;
            self.content = Content(resourceAccount: resourceAccount, link: link, data: data);
            self.session = session;

            // hash message info, the same as in `toBytes()`
            var raw_data: [UInt8] = [];

            // raw_data = raw_data.concat(self.id.toBigEndianBytes());
            raw_data = raw_data.concat(MessageProtocol.to_be_bytes_u128(self.id));
            raw_data = raw_data.concat(self.fromChain.utf8);
            raw_data = raw_data.concat(self.toChain.utf8);

            raw_data = raw_data.concat(self.sqos.toBytes());
            // `contractName`, `actionName`, `data` are all in `content`
            raw_data = raw_data.concat(self.content.toBytes());

            raw_data = raw_data.concat(self.sender);
            raw_data = raw_data.concat(self.signer);

            raw_data = raw_data.concat(self.session.toBytes());


            let digest = HashAlgorithm.KECCAK_256.hash(raw_data);
            self.messageHash = String.encodeHex(digest);
        }

        pub fun getRecvMessageHash(): [UInt8] {
            return self.messageHash.decodeHex();
        }

        pub fun toBytes(): [UInt8] {
            var raw_data: [UInt8] = [];

            // raw_data = raw_data.concat(self.id.toBigEndianBytes());
            raw_data = raw_data.concat(MessageProtocol.to_be_bytes_u128(self.id));
            raw_data = raw_data.concat(self.fromChain.utf8);
            raw_data = raw_data.concat(self.toChain.utf8);

            raw_data = raw_data.concat(self.sqos.toBytes());
            // `contractName`, `actionName`, `data` are all in `content`
            raw_data = raw_data.concat(self.content.toBytes());

            raw_data = raw_data.concat(self.sender);
            raw_data = raw_data.concat(self.signer);

            raw_data = raw_data.concat(self.session.toBytes());

            return raw_data;
        }

        access(contract) fun setAbandoned() {
            self.messageHash = "00";
        }
    }

    pub struct messageCopy {
        pub let messageInfo: ReceivedMessageCore;
        pub let submitters: [Address];
        pub(set) var credibility: UFix64;

        init(om: ReceivedMessageCore) {
            self.messageInfo = om;
            self.submitters = [];
            self.credibility = 0.0;
        }

        pub fun addSubmitter(submitter: Address) {
            self.submitters.append(submitter);
        }

        pub fun checkExisted(submitter: Address): Bool {
            for ele in self.submitters {
                if (ele == submitter) {
                    return true;
                }
            }

            return false;
        }
    }

    // Define received message array
    pub struct ReceivedMessageCache{
        pub let msgInstance: {String: messageCopy};
        pub let msgID: UInt128;
        priv var msgCount: Int;

        init(id: UInt128){
            self.msgInstance = {};
            self.msgID = id;
            self.msgCount = 0;
        }

        pub fun insert(receivedMessageCore: ReceivedMessageCore, pubAddr: Address){
            if self.checkSubmitterExisted(pubAddr: pubAddr) {
                panic("Repeatedly submit messages with the same id from the same address.");
            }
            
            // Add to related messageCopy
            if (self.msgInstance.containsKey(receivedMessageCore.messageHash)) {
                self.msgInstance[receivedMessageCore.messageHash]!.addSubmitter(submitter: pubAddr);
            } else {
                let mCopy = messageCopy(om: receivedMessageCore);
                mCopy.addSubmitter(submitter: pubAddr);
                self.msgInstance.insert(key: receivedMessageCore.messageHash, mCopy);
            }
            self.msgCount = self.msgCount + 1;
        }

        pub fun getMessageCount(): Int{
            // var sum: Int = 0;
            // for ele in self.msgInstance.values {
            //     sum = sum + ele.submitters.length;
            // }
            // return sum;
            return self.msgCount;
        }

        pub fun checkSubmitterExisted(pubAddr: Address): Bool {
            for ele in self.msgInstance.values {
                if ele.checkExisted(submitter: pubAddr) {
                    return true;
                }
            }

            return false;
        }
    }

    // define resource to stores received cross chain message 
    pub resource ReceivedMessageVault: ReceivedMessageInterface{
        // key is `fromChain`
        pub let message: {String: [ReceivedMessageCache]};
        pub let executableCount: Int;
        // pub var completedID: {String: UInt128};   
        priv var online: Bool;
        priv var defaultCopyCount: Int;
        
        pub let execCache: [ReceivedMessageCore];
        pub let historyStorage: {String: [ReceivedMessageCache]};
        // TODO: context

        init(){
            self.message = {};
            self.executableCount = 10;
            //self.completedID = {};
            self.online = true;
            self.defaultCopyCount = 1; // TODO defaultCopyCount = 1, debug only

            self.execCache = [];
            self.historyStorage = {};
        }

        /**
          * add cross chain message to ReceivedMessageVault
          * @param messageId - message id
          * @param fromChain - source chain
          * @param contractName - contract name of source chain
          * @param actionName - action name of source contract
          * @param data - contract execute data
        **/
        pub fun submitRecvMessage(recvMsg: ReceivedMessageCore, 
                                  pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]){
            // Verify the submitter
            if (!SettlementContract.isSelected(recvAddr: self.owner!.address, router: pubAddr)) {
                panic("Invalid Validator. Unregistered or Currently not Selected.")
            }

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: pubAddr, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              rawData: recvMsg.messageHash.decodeHex(),
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA3_256)) {
                panic("Signature verification failed!");
            } 
            //else {
            //    log("Signature verification success!");
            //    return;
            //}

            self._submitRecvMessage(recvMsg: recvMsg, pubAddr: pubAddr);
        }

        priv fun _submitRecvMessage(recvMsg: ReceivedMessageCore, pubAddr: Address) {
            var cacheIdx: Int = -1;
            
            if (self.message.containsKey(recvMsg.fromChain)) {
                let caches: &[ReceivedMessageCache] = &self.message[recvMsg.fromChain]! as &[ReceivedMessageCache];

                var found = false;
                
                for idx, ele in self.message[recvMsg.fromChain]! {
                    if (recvMsg.id == ele.msgID) {
                        self.message[recvMsg.fromChain]![idx].insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                        cacheIdx = idx;
                        found = true;
                        break;
                    }
                }
                
                // received a new message
                if (!found) {

                    var maxRecvedID: UInt128 = 0;
                    if let recvID = ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] {
                        maxRecvedID = recvID;
                    } else {
                        ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] = 0;
                    }

                    if (recvMsg.id == (maxRecvedID + 1)) {
                        // TODO: this strategy need to be checked!
                        let mcache = ReceivedMessageCache(id: recvMsg.id);
                        mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                        caches.append(mcache);

                        ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] = recvMsg.id;

                        cacheIdx = caches.length - 1;
                    } else {
                        panic("Invalid `recvMsg` ID!");
                    }
                }

            } else {
                var maxRecvedID: UInt128 = 0;
                if let recvID = ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] {
                    maxRecvedID = recvID;
                } else {
                    ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] = 0;
                }

                if recvMsg.id  == (maxRecvedID + 1) {
                    let mcache = ReceivedMessageCache(id: recvMsg.id);
                    mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                    self.message[recvMsg.fromChain] = [mcache];

                    ReceivedMessageContract.maxRecvedID[recvMsg.fromChain] = recvMsg.id;

                    cacheIdx = 0;
                } else {
                    panic("Invalid `recvMsg` ID!");
                }
            }

            if (cacheIdx >= 0) {
                if (self.message[recvMsg.fromChain]![cacheIdx].getMessageCount() >= self.defaultCopyCount) {
                    // Move the message to `execCache` 
                    let msgCache = self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                    self.addHistory(fromChain: recvMsg.fromChain, msgCache: msgCache);
                    
                    // do verification
                    let msgVerified = self.messageVerify(messageCache: msgCache);
                    
                    if msgVerified == nil {
                        return;
                    }

                    self.execCache.append(msgVerified!);
                }
            }
        }

        priv fun increaseCompleteID(fromChain: String, recvID: UInt128) {
            if let cplID = ReceivedMessageContract.completedID[fromChain] {
                if (cplID < recvID) {
                    ReceivedMessageContract.completedID[fromChain] = recvID;
                }
            } else {
                ReceivedMessageContract.completedID[fromChain] = recvID;
            }
        }
 
        pub fun getCompleteID(): {String: UInt128}{
            return ReceivedMessageContract.completedID;
        }

        pub fun getNextMessageID(submitterAddr: Address): {String: UInt128} {
            let nextIDs = ReceivedMessageContract.maxRecvedID;

            for key in nextIDs.keys {
                nextIDs[key] = nextIDs[key]! + 1;
            }

            for ele in self.message.keys {
                let recvMsgCache = self.message[ele]!;

                for recvMsgEle in recvMsgCache {
                    if !recvMsgEle.checkSubmitterExisted(pubAddr: submitterAddr) {
                        nextIDs[ele] = recvMsgEle.msgID;
                        break;
                    }
                }
            }

            return nextIDs;
        }

        pub fun isOnline(): Bool {
            return self.online;
        }

        pub fun setOnline() {
            self.online = true;
        }

        pub fun setOffline() {
            self.online = false;
        }

        pub fun setCopyCount(count: Int) {
            if (count > 0) {
                self.defaultCopyCount = count;
            } else {
                panic("Invalid input parameter!");
            }
        }

        /**
          * Do verification for one message including many copies
          * @param messageId - message id
        **/
        pub fun messageVerify(messageCache: ReceivedMessageCache): ReceivedMessageCore? {
            var honest: [Address] = [];
            var evil: [Address] = [];
            var exception: {Address: UFix64} = {};
            
            if messageCache.msgInstance.values.length == 1 {
                SettlementContract.workingNodesTrail(honest: messageCache.msgInstance.values[0].submitters, evil: [], exception: {});
                return messageCache.msgInstance.values[0].messageInfo;
            }
            
            var crdSum = 0.0;
            // Calculate credibilities of `messageCopy`
            for k in messageCache.msgInstance.keys {
                if let msgCopyRef: &messageCopy = &messageCache.msgInstance[k] as &messageCopy? {
                    for submitter in msgCopyRef.submitters {
                        msgCopyRef.credibility = msgCopyRef.credibility + (SettlementContract.getCredibility(router: submitter) ?? panic("submitter not existed."));
                    }

                    crdSum = crdSum + msgCopyRef.credibility;
                }
            }

            var recvMsgCore: ReceivedMessageCore? = nil;
            // var maxCopyKey: String = "";
            // var maxCredibility = 0.0;
            // Normalization and check the verification threshold
            for k in messageCache.msgInstance.keys {
                if let msgCopyRef: &messageCopy = &messageCache.msgInstance[k] as &messageCopy? {
                    msgCopyRef.credibility = msgCopyRef.credibility / crdSum;
                    
                    log("Message copy hash: ".concat(msgCopyRef.messageInfo.messageHash).concat(". Credibility: ").concat(msgCopyRef.credibility.toString()));

                    if msgCopyRef.credibility >= ReceivedMessageContract.vfThreshold {
                        recvMsgCore = msgCopyRef.messageInfo;
                        honest = msgCopyRef.submitters;
                    } else {
                        for ele in msgCopyRef.submitters {
                            exception[ele] = msgCopyRef.credibility;
                        }
                    }
                }
            }

            // no message copy has enough credibility
            if recvMsgCore == nil {
                SettlementContract.workingNodesTrail(honest: [], evil: [], exception: exception);
            } else {
                evil = exception.keys;
                SettlementContract.workingNodesTrail(honest: honest, evil: evil, exception: {});
            }

            return recvMsgCore;
        }

        /**
          * Trigger the execution in the head
        **/
        pub fun trigger() {
            if self.isExecutable() {
                let msgVerified = self.execCache.removeFirst();
                
                // TODO: Move out
                let msgContent = msgVerified!.content;

                // TODO: call destination
                let pubLink = PublicPath(identifier: msgContent.link);
                if (nil == pubLink)
                {
                    self.increaseCompleteID(fromChain: msgVerified.fromChain, recvID: msgVerified.id);
                    return;
                    //panic("invalid `link` path!");
                }

                // let calleeRef = getAccount(address).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
                let calleeRef = getAccount(msgContent.accountAddress).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow();
                if (nil == calleeRef){
                    self.increaseCompleteID(fromChain: msgVerified.fromChain, recvID: msgVerified.id);
                    return;
                    //panic("invalid callee address or `link`!");
                }

                // TODO: concrete invocations need to be move out to a special cache, 
                // and be invocated by off-chain nodes
                // let contextID = msgVerified!.fromChain.concat(msgVerified!.id.toString());
                ContextKeeper.setContext(context: ContextKeeper.Context(id: msgVerified!.id,
                                                                        fromChain: msgVerified!.fromChain,
                                                                        sender: msgVerified!.sender,
                                                                        signer: msgVerified!.signer,
                                                                        sqos: msgVerified!.sqos,
                                                                        session: msgVerified!.session));
                calleeRef!.callMe(data: msgContent.data);
                ContextKeeper.clearContext();

                self.increaseCompleteID(fromChain: msgVerified.fromChain, recvID: msgVerified.id);
            }
        }

        // check if there are executions to be triggered
        pub fun isExecutable(): Bool {
            return self.execCache.length > 0;
        }

        // get all executions to be triggered
        pub fun getExecutions(): [ReceivedMessageCore] {
            return self.execCache;
        }

        /**
          * add received message copies to history storage
          * @param fromChain - the source chain of the message
          * @param msgCache - one message with its copies
        **/
        priv fun addHistory(fromChain: String, msgCache: ReceivedMessageCache) {
            if let chainCacheRef: &[ReceivedMessageCache] = (&self.historyStorage[fromChain] as &[ReceivedMessageCache]?) {
                chainCacheRef.append(msgCache);
            } else {
                self.historyStorage[fromChain] = [msgCache];
            }
        }

        pub fun getHistory(): {String: [ReceivedMessageCache]} {
            return self.historyStorage;
        }

        /*
         * when submitting or executing messages, abnormal situations may happen. 
         * As we cannot directly process exceptions on-chain, we need a mechanism for off-chain routers to submit error things
         *
         * This need to wait all selected routers submitted the error 
        */
        pub fun submitAbandoned(msgID: UInt128, fromChain: String, 
                                pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]) {

            // Verify the submitter
            if (!SettlementContract.isSelected(recvAddr: self.owner!.address, router: pubAddr)) {
                panic("Invalid Validator. Unregistered or Currently not Selected.")
            }

            ///////////////////////////////////////////////////////////////////////////
            // judge validation of the message
            var maxRecvedID: UInt128 = 0;
            if let recvID = ReceivedMessageContract.maxRecvedID[fromChain] {
                maxRecvedID = recvID;
            } else {
                ReceivedMessageContract.maxRecvedID[fromChain] = 0;
            }
            ///////////////////////////////////////////////////////////////////////////

            let rawData = MessageProtocol.to_be_bytes_u128(msgID).concat(fromChain.utf8);

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: pubAddr, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              rawData: rawData,
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA3_256)) {
                panic("Signature verification failed!");
            } 

            let recvMsg = ReceivedMessageCore(id: msgID, fromChain: fromChain, sender: [], signer: [], sqos: MessageProtocol.SQoS(), 
                                                resourceAccount: 0x00, link: "", data: MessageProtocol.MessagePayload(),
                                                session: MessageProtocol.Session(oId: msgID, oType: 0, oCallback: nil, oc: nil, oa: nil));
            
            recvMsg.setAbandoned();

            var isExecutable = false;
            // check if it's in `execCache`
            for idx, ele in self.execCache {
                if (ele.id == msgID) && (ele.fromChain == fromChain) {
                    isExecutable = true;
                    break;
                }
            }

            if !isExecutable {
                self._submitRecvMessage(recvMsg: recvMsg, pubAddr: pubAddr);
            }
        }
    }

    // Temporarily, verification threshold is setted to be 0.7 when contract deployed
    // This will be moved to Resource `ReceivedMessageVault` when developing `SQoS` features
    // This value must be larger than 0.5
    pub let vfThreshold: UFix64;

    access(contract) let completedID: {String: UInt128}; 
    
    access(contract) let maxRecvedID: {String: UInt128};

    init() {
        self.vfThreshold = 0.7;
        self.completedID = {};
        self.maxRecvedID = {};
    }

    // Create recource to store received message
    pub fun createReceivedMessageVault():@ReceivedMessageVault{
        // TODO
        /**
          * record the resouces' `public/link`
          */
        return <- create ReceivedMessageVault();
    }
    
    // Query completedID by identifier
    pub fun queryCompletedID(): {String: UInt128}{
      //let pubLink = PublicPath(identifier: link);
      //let ReceivedMessageVaultRef = getAccount(recvAddress).getCapability<&{ReceivedMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
      //return ReceivedMessageVaultRef.getCompleteID();
      return self.completedID;
    }

    pub fun queryMaxRecvedID(): {String: UInt128} {
        return self.maxRecvedID;
    }

    pub fun getRecverRef(recverAddress: Address, link: String): &{ReceivedMessageContract.ReceivedMessageInterface}? {
        let pubLink = PublicPath(identifier: link);
        let recver = getAccount(recverAddress).getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(pubLink!);
        return recver.borrow();
    }

    //////////////////////////////////////////////////////////////////////
    // Temporary test
    pub fun testPanic() {
        panic("Something error!");
    }
}

 