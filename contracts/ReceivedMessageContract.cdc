import MessageProtocol from "./MessageProtocol.cdc";
import IdentityVerification from "./IdentityVerification.cdc";
import SettlementContract from "./Settlement.cdc";
import ContextKeeper from "./ContextKeeper.cdc";
import SentMessageContract from "./SentMessageContract.cdc";
import OmniverseInformation from "./OmniverseInformation.cdc"
import CrossChain from "./CrossChain.cdc"
import SQoSEngine from "./SQoSEngine.cdc"

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

        pub fun submitHidden(hidden: SQoSEngine.HiddenData, 
                            pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]);
        
        pub fun submitReveal(recvMsg: ReceivedMessageCore, 
                                pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8], randNumber: UInt32);

        pub fun isOnline(): Bool;

        // Execution
        pub fun trigger(msgID: UInt128, fromChain: String);
        pub fun isExecutable(): Bool;
        pub fun getExecutions(): [ExecData];
        pub fun getAbandonedExecs(): [ExecData];

        // history
        pub fun getHistory(): {String: [ReceivedMessageCache]};
        pub fun getEvilHistory(): {String: [ReceivedMessageCache]};

        // SQoS
        pub fun getSQoS(): MessageProtocol.SQoS?;
        pub fun makeChallenge(challenger: Address, fromChain: String, msgID: UInt128, 
                                signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]);
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
            self.messageHash = OmniverseInformation.emptyHash;
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
        pub var msgInstance: {String: messageCopy};
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

        pub fun clearInstance() {
            self.msgInstance = {};
            self.msgCount = 0;
        }
    }

    pub struct VerifiedMessage {
        pub let messageCore: ReceivedMessageCore;
        pub let submitters: [Address];

        init(verified: ReceivedMessageCore, submitters: [Address]) {
            self.messageCore = verified;
            self.submitters = submitters;
        }
    }

    pub struct ExecData {
        pub let verifiedMessage: VerifiedMessage;
        pub let abandonApply: [Address];

        /////////////////////////////////////////////////////
        // optimistic
        // The challenge 
        priv var execTime: UFix64;
        pub var challenged: Bool;
        pub let challengers: [Address];
        priv var selectedChallengers: [Address];

        init(verifiedMessage: VerifiedMessage) {
            self.verifiedMessage = verifiedMessage;
            self.abandonApply = [];
            self.execTime = getCurrentBlock().timestamp;
            self.challenged = true;
            self.challengers = [];
            self.selectedChallengers = [];
        }

        pub fun applyAbandon(_ addr: Address) {
            self.abandonApply.append(addr);
        }

        /////////////////////////////////////////////////////
        // optimistic
        pub fun setExecTime(et: UFix64) {
            self.execTime = et;
            self.challenged = false;
            let cNum: UInt32 = UInt32(UFix64(SettlementContract.getSysValidatorNumber())* 1.5);
            self.selectedChallengers = SettlementContract.select(tobeSelect: cNum);
        }

        pub fun getSelectedChallengers(): [Address] {
            return self.selectedChallengers;
        }

        pub fun makeChallenge(_ addr: Address) {
            //log(".................prepare adding challenger: ".concat(addr.toString()));
            if self.execTime >= getCurrentBlock().timestamp {
                // TODO: Remember to check the `selectedChallengers`
                //log(".................adding challenger: ".concat(addr.toString()));
                if (!self.challengers.contains(addr))/* && (self.selectedChallengers.contains(addr))*/ {
                    self.challengers.append(addr);
                    //log(".................added challenger: ".concat(addr.toString()));
                }
            }
        }

        // -1: challengers win, reject message; 0: still waiting; 1: submitters win, accept message;
        pub fun challengeSettle(): Int {
            log(self.execTime.toString());
            log(getCurrentBlock().timestamp.toString());
            
            if self.challenged {
                return 1;
            }

            if self.execTime > getCurrentBlock().timestamp {
                return 0;
            } else {
                // TODO: settlement of optimistic
                let submissionCrd = self._crd_sum(addresses: self.verifiedMessage.submitters);
                let challengeCrd = self._crd_sum(addresses: self.challengers);
                if challengeCrd > submissionCrd {
                    SettlementContract.workingNodesTrail(honest: [], evil: self.verifiedMessage.submitters, exception: {});
                    return -1;
                } else {
                    SettlementContract.workingNodesTrail(honest: [], evil: self.challengers, exception: {});
                    self.challenged = true;
                    return 1;
                }
            }
        }

        priv fun _crd_sum(addresses: [Address]): UFix64 {
            var crdSum: UFix64 = 0.0;
            for ele in addresses {
                if let crd = SettlementContract.getCredibility(router: ele) {
                    crdSum = crdSum + crd;
                }
            }

            return crdSum;
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
        
        pub let execCache: [ExecData];
        pub let execAbandon: [ExecData];

        pub let historyStorage: {String: [ReceivedMessageCache]};

        pub let evilHistory: {String: [ReceivedMessageCache]};
        
        // SQoS
        priv var sqos: MessageProtocol.SQoS?;
        priv var hrHandle: @SQoSEngine.HiddenReveal?;

        priv var vfThreshold: UFix64;

        init(){
            self.message = {};
            self.executableCount = 10;
            //self.completedID = {};
            self.online = true;
            self.defaultCopyCount = 1; // TODO defaultCopyCount = 1, debug only

            self.execCache = [];
            self.execAbandon = [];

            self.historyStorage = {};
            self.evilHistory = {};

            self.sqos = nil;
            self.hrHandle <- nil;

            self.vfThreshold = ReceivedMessageContract.vfThreshold;
        }

        access(contract) destroy() {
            destroy self.hrHandle;
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

            if let sqos = self.sqos {
                if sqos.checkItem(type: MessageProtocol.SQoSType.Reveal) != nil {
                    panic("Need submission with `submitHidden` and `submitReveal`");
                }
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
                    let msgCache = self.message[recvMsg.fromChain]![cacheIdx];
                    //let msgCacheRef = &(self.message[recvMsg.fromChain]![cacheIdx]) as &ReceivedMessageCache;
                    
                    // do verification
                    let msgVerified = self.messageVerify(messageCache: msgCache);
                    
                    if msgVerified == nil {
                        // TODO: add evil history
                        //msgCacheRef.clearInstance();
                        self.message[recvMsg.fromChain]![cacheIdx].clearInstance();
                        return;
                    }

                    let execData = ExecData(verifiedMessage: msgVerified!);
                    if let sqos = self.sqos {
                        //log("Setting SQoS.......");
                        if let idx = sqos.checkItem(type: MessageProtocol.SQoSType.Challenge) {
                            //log("Optimistic.......");
                            log(getCurrentBlock().timestamp.toString());
                            let endTime: UFix64 = getCurrentBlock().timestamp + UFix64(MessageProtocol.UInt32_from_be_bytes(bytes: sqos.sqosItems[idx].v));
                            execData.setExecTime(et: endTime);
                            //log(endTime.toString());    
                        }
                    }

                    // if there is exception, abandoned directly
                    if msgVerified!.messageCore.messageHash == OmniverseInformation.emptyHash {
                        // This is a message abandoned
                        self._dropAbandoned(execData);
                        self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                    } else {
                        // record this message
                        self.addHistory(fromChain: recvMsg.fromChain, msgCache: msgCache);
                        self.execCache.append(execData);
                    }

                    /*
                    if msgVerified!.messageHash == OmniverseInformation.emptyHash {
                        // This is a message abandoned
                        self._dropAbandoned(ExecData(verifiedMessage: msgVerified!));
                        self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                    } else {
                        var tbChallenge = false;
                        if let sqos = self.sqos {
                            if sqos.checkItem(type: MessageProtocol.SQoSType.Challenge) {
                                tbChallenge = true;
                            }
                        }

                        if tbChallenge {
                            // TODO: make a challenge

                        } else {
                            // record this message
                            self.addHistory(fromChain: recvMsg.fromChain, msgCache: msgCache);
                            self.execCache.append(ExecData(verifiedMessage: msgVerified!));
                        }
                    }*/
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
        pub fun messageVerify(messageCache: ReceivedMessageCache): VerifiedMessage? {
            var honest: [Address] = [];
            var evil: [Address] = [];
            var exception: {Address: UFix64} = {};
            
            if messageCache.msgInstance.values.length == 1 {
                SettlementContract.workingNodesTrail(honest: messageCache.msgInstance.values[0].submitters, evil: [], exception: {});
                return VerifiedMessage(verified: messageCache.msgInstance.values[0].messageInfo, submitters: messageCache.msgInstance.values[0].submitters);
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

                    if msgCopyRef.credibility >= self.vfThreshold {
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
                return nil;
            } else {
                evil = exception.keys;
                SettlementContract.workingNodesTrail(honest: honest, evil: evil, exception: {});
                return VerifiedMessage(verified: recvMsgCore!, submitters: honest);
            }
        }

        /**
          * Trigger the execution in the head
        **/
        pub fun trigger(msgID: UInt128, fromChain: String) {
            // TODO: make challenge
            self._challege_settle();
            /////////////////////////////////////////////////////////////////
            if self.isExecutable() {
                var triggerIdx = 0;
                var fetchMessage: ReceivedMessageCore? = nil;
                while triggerIdx < self.execCache.length {
                    if (self.execCache[triggerIdx].verifiedMessage.messageCore.id == msgID) && 
                        (self.execCache[triggerIdx].verifiedMessage.messageCore.fromChain == fromChain) &&
                        self.execCache[triggerIdx].challenged {

                        fetchMessage = self.execCache.remove(at: triggerIdx).verifiedMessage.messageCore;
                        // TODU: remove from recv cache to history
                        break;
                    }
                    
                    triggerIdx = triggerIdx + 1;
                }

                if fetchMessage == nil {
                    return;
                }
                
                let msgVerified = fetchMessage!;

                if msgVerified.messageHash == OmniverseInformation.emptyHash {
                    // the verified message is abandoned
                    panic("Abandoned message!");
                    // return;
                }

                // Process Error Message
                if msgVerified.session.type == OmniverseInformation.remoteError {
                    self._process_remote_error(msgVerified);
                } else if UInt8(3) == msgVerified.session.type {
                    self._process_remote_back(msgVerified);
                } else if UInt8(2) == msgVerified.session.type {
                    self._process_remote_call(msgVerified);
                } else if UInt8(1) == msgVerified.session.type {
                    self._process_remote_normal(msgVerified);
                } else {
                    panic("Undefined session type: ".concat(msgVerified.session.type.toString()));
                }

                self.increaseCompleteID(fromChain: msgVerified.fromChain, recvID: msgVerified.id);
            }
        }

        // check if there are executions to be triggered
        pub fun isExecutable(): Bool {
            return self.execCache.length > 0;
        }

        // get all executions to be triggered
        pub fun getExecutions(): [ExecData] {
            return self.execCache;
        }

        // get all abandoned executions
        pub fun getAbandonedExecs(): [ExecData] {
            return self.execAbandon;
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

        priv fun addEvilHistory(fromChain: String, msgCache: ReceivedMessageCache) {
            if let chainCacheRef: &[ReceivedMessageCache] = (&self.evilHistory[fromChain] as &[ReceivedMessageCache]?) {
                chainCacheRef.append(msgCache);
            } else {
                self.evilHistory[fromChain] = [msgCache];
            }
        }

        pub fun getEvilHistory(): {String: [ReceivedMessageCache]} {
            return self.evilHistory;
        }

        /*
         * This is used for SQoS `Hidden & Reveal`
         * A hidden message will be submitted before the plain text, and the values of the hidden are different from different submitters even if the real contents are the same
        */
        pub fun submitHidden(hidden: SQoSEngine.HiddenData, 
                            pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]) {
            
            /*if let sqos = self.sqos {
                if sqos.checkItem(type: MessageProtocol.SQoSType.Reveal) == nil {
                    panic("No `Hidden & Reveal` SQoS item!");
                }
            }*/
            
            // Verify the submitter
            if (!SettlementContract.isSelected(recvAddr: self.owner!.address, router: pubAddr)) {
                panic("Invalid Validator. Unregistered or Currently not Selected.")
            }

            let rawData = hidden.rawCMT.decodeHex();

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: pubAddr, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              rawData: rawData,
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA3_256)) {
                panic("Signature verification failed!");
            } 

            (&self.hrHandle as &SQoSEngine.HiddenReveal?)!.submitHidden(submitter: pubAddr, hidden: hidden);
        }

        pub fun getHiddenRecords(): {String: {Address: SQoSEngine.HRRecord}} {
            return (&self.hrHandle as &SQoSEngine.HiddenReveal?)!.getHiddenRecords();
        }

        pub fun submitReveal(recvMsg: ReceivedMessageCore, 
                                pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8], randNumber: UInt32) {
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

            if (&self.hrHandle as &SQoSEngine.HiddenReveal?)!.submitReveal(submitter: pubAddr, 
                                        fromChain: recvMsg.fromChain, 
                                        msgID: recvMsg.id, 
                                        rvData: SQoSEngine.RevealData(messageHash: recvMsg.messageHash, randNumber: randNumber)) {
                self._submitRecvMessage(recvMsg: recvMsg, pubAddr: pubAddr);
            }
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

            let rawData = MessageProtocol.to_be_bytes_u128(msgID).concat(fromChain.utf8);

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: pubAddr, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              rawData: rawData,
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA3_256)) {
                panic("Signature verification failed!");
            } 

            var isExecutable = false;
            var toBeRemove = -1;
            // check if it's in `execCache`
            for idx, ele in self.execCache {
                if (ele.verifiedMessage.messageCore.id == msgID) && (ele.verifiedMessage.messageCore.fromChain == fromChain) {
                    isExecutable = true;

                    self.execCache[idx].applyAbandon(pubAddr);
                    if self.execCache[idx].abandonApply.length >= self.defaultCopyCount {
                        toBeRemove = idx;
                    }

                    break;
                }
            }

            if toBeRemove >= 0 {
                self._dropAbandoned(self.execCache.remove(at: toBeRemove));
            }

            if !isExecutable {
                let recvMsg = ReceivedMessageCore(id: msgID, fromChain: fromChain, sender: [], signer: [], sqos: MessageProtocol.SQoS(), 
                                                resourceAccount: 0x00, link: "", data: MessageProtocol.MessagePayload(),
                                                session: MessageProtocol.Session(oId: msgID, oType: OmniverseInformation.errorType, oCallback: nil, oc: nil, oa: nil));
            
                recvMsg.setAbandoned();

                self._submitRecvMessage(recvMsg: recvMsg, pubAddr: pubAddr);
            }
        }

        priv fun _dropAbandoned(_ msg: ExecData) {
            // self.owner is only a PublicAccount
            // let submitterRef = self.owner!.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter)!;
            SentMessageContract.sendoutErrorNotification(msgID: msg.verifiedMessage.messageCore.id, 
                                                        toChain: msg.verifiedMessage.messageCore.fromChain/*, 
                                                        submitterRef: submitterRef, 
                                                        acceptor: self.owner!.address, 
                                                        alink: "sentMessageVault", 
                                                        slink: "msgSubmitter"*/);

            self.execAbandon.append(msg);
        }

        /*
         * Concrete implementation for processing received messages
        */
        // processing remote call
        priv fun _process_remote_call(_ msg: ReceivedMessageCore) {
            self._process_remote_normal(msg);
        }

        // processing remote send/call out
        priv fun _process_remote_normal(_ msgVerified: ReceivedMessageCore) {
            // Move out
            let msgContent = msgVerified.content;

            // call destination
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
            // let contextID = msgVerified.fromChain.concat(msgVerified.id.toString());
            ContextKeeper.setContext(context: ContextKeeper.Context(id: msgVerified.id,
                                                                    fromChain: msgVerified.fromChain,
                                                                    sender: msgVerified.sender,
                                                                    signer: msgVerified.signer,
                                                                    sqos: msgVerified.sqos,
                                                                    session: msgVerified.session));
            calleeRef!.callMe(data: msgContent.data);
            ContextKeeper.clearContext();
        }

        // processing remote callback
        priv fun _process_remote_back(_ msg: ReceivedMessageCore) {
            let cbRecord = SentMessageContract.getCallback(remoteChain: msg.fromChain, sessionID: msg.session.id);

            if (nil == cbRecord) {
                log("No related callback function");
                return;
            }

            if (cbRecord!.srcAddr != msg.content.accountAddress) || (cbRecord!.callback != msg.content.link) {
                log("Callback not matched!");
                return;
            }

            // call destination
            let pubLink = PublicPath(identifier: cbRecord!.callback);
            if (nil == pubLink) {
                return;
            }

            let calleeRef = getAccount(cbRecord!.srcAddr).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow();
            if (nil == calleeRef){
                return;
            }

            ContextKeeper.setContext(context: ContextKeeper.Context(id: msg.id,
                                                                    fromChain: msg.fromChain,
                                                                    sender: msg.sender,
                                                                    signer: msg.signer,
                                                                    sqos: msg.sqos,
                                                                    session: msg.session));
            
            calleeRef!.callMe(data: msg.content.data);

            ContextKeeper.clearContext();

            SentMessageContract.deleteCallback(toChain: msg.fromChain, sessionID: msg.session.id);
        }

        // processing remote error
        priv fun _process_remote_error(_ msg: ReceivedMessageCore) {
            var fetchSentMessage: SentMessageContract.SentMessageCore? = nil;
            for sendKey in CrossChain.registeredSendAccounts.keys {
                if let senderRef = SentMessageContract.getSenderRef(senderAddress: sendKey, link: CrossChain.registeredSendAccounts[sendKey]!) {
                    if let messageInstance = senderRef.getMessageById(chain: msg.fromChain, messageId: msg.session.id) {
                        fetchSentMessage = messageInstance;
                        break;
                    }
                }
            }

            if (nil == fetchSentMessage) {
                log("No related message");
                return;
            }

            if (msg.session.id != fetchSentMessage!.session.id) {
                log("Remote Error: Mismatched session id.")
                return;
            }

            if UInt8(2) == fetchSentMessage!.session.type {
                let cbRecord = SentMessageContract.getCallback(remoteChain: msg.fromChain, sessionID: msg.session.id);

                if (nil == cbRecord) {
                    log("No related callback function");
                    return;
                }

                // call destination
                let pubLink = PublicPath(identifier: cbRecord!.callback);
                if (nil == pubLink) {
                    return;
                }

                let calleeRef = getAccount(cbRecord!.srcAddr).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow();
                if (nil == calleeRef){
                    return;
                }

                ContextKeeper.setContext(context: ContextKeeper.Context(id: msg.id,
                                                                        fromChain: msg.fromChain,
                                                                        sender: [],
                                                                        signer: [],
                                                                        sqos: fetchSentMessage!.sqos,
                                                                        session: msg.session));
                
                // let data = OmniverseInformation.createErrorPayload(errorCode: msg.session.type);
                calleeRef!.callMe(data: msg.content.data);

                ContextKeeper.clearContext();

                SentMessageContract.deleteCallback(toChain: msg.fromChain, sessionID: msg.session.id);
            }
        }

        pub fun setSQoS(sqos: MessageProtocol.SQoS) { 
            self.sqos = sqos;

            // create hidden reveal handle
            if self.sqos!.checkItem(type: MessageProtocol.SQoSType.Reveal) != nil {
                self.hrHandle <-! SQoSEngine.createHiddenReveal(defaultCopyCount: self.defaultCopyCount);
            }

            // threshold
            if let idx = sqos.checkItem(type: MessageProtocol.SQoSType.Threshold) {
                self.vfThreshold = UFix64(MessageProtocol.UInt32_from_be_bytes(bytes: sqos.sqosItems[idx].v)) / 100.0;
            }
        }

        pub fun addSQoSItem(item: MessageProtocol.SQoSItem) {
            if let sqosRef: &MessageProtocol.SQoS = &self.sqos as &MessageProtocol.SQoS? {
                sqosRef.updateItem(item: item);
            } else {
                let sqos = MessageProtocol.SQoS();
                sqos.addItem(item: item);
                self.setSQoS(sqos: sqos);
            }

            // create hidden reveal handle
            if item.t == MessageProtocol.SQoSType.Reveal.rawValue {
                if self.hrHandle == nil {
                    self.hrHandle <-! SQoSEngine.createHiddenReveal(defaultCopyCount: self.defaultCopyCount);
                }
            }

            // threshold
            if item.t == MessageProtocol.SQoSType.Threshold.rawValue {
                self.vfThreshold = UFix64(MessageProtocol.UInt32_from_be_bytes(bytes: item.v)) / 100.0;
            }
        }

        pub fun deleteSQoSItem(type: MessageProtocol.SQoSType) {
            if let sqosRef: &MessageProtocol.SQoS = &self.sqos as &MessageProtocol.SQoS? {
                sqosRef.deleteItem(type: type);
            }

            // hidden reveal
            if type == MessageProtocol.SQoSType.Reveal {
                var temp: @SQoSEngine.HiddenReveal? <- nil;
                temp <-> self.hrHandle;
                destroy temp;
            }

            // threshold
            if type == MessageProtocol.SQoSType.Threshold {
                self.vfThreshold = ReceivedMessageContract.vfThreshold;
            }
        }

        pub fun getSQoS(): MessageProtocol.SQoS? {
            return self.sqos;
        }

        //////////////////////////////////////////////
        priv fun _query_cache_idx(fromChain: String, msgID: UInt128): Int? {
            if let msgsInChain = self.message[fromChain] {
                for idx, ele in msgsInChain {
                    if ele.msgID == msgID {
                        return idx;
                    }
                }
            } 

            return nil;
        }

        // Optimistic
        priv fun _challege_settle() {
            var execIdx: Int = 0;
            let tobeRemove: [Int] = [];
            while execIdx < self.execCache.length {
                let rst = self.execCache[execIdx].challengeSettle();
                
                if rst == 1 {
                    if let cacheIdx = self._query_cache_idx(fromChain: self.execCache[execIdx].verifiedMessage.messageCore.fromChain, 
                                                                msgID: self.execCache[execIdx].verifiedMessage.messageCore.id){
                        // remove message instance from `self.message[...]` and add to history
                        let recvCache = self.message[self.execCache[execIdx].verifiedMessage.messageCore.fromChain]!.remove(at: cacheIdx);
                        self.addHistory(fromChain: self.execCache[execIdx].verifiedMessage.messageCore.fromChain, msgCache: recvCache);                                            
                    }
                } else if rst == -1 {
                    if let cacheIdx = self._query_cache_idx(fromChain: self.execCache[execIdx].verifiedMessage.messageCore.fromChain, 
                                                                msgID: self.execCache[execIdx].verifiedMessage.messageCore.id){
                        // clear message instance from `self.message[...]`
                        self.message[self.execCache[execIdx].verifiedMessage.messageCore.fromChain]![cacheIdx].clearInstance();
                        log(".....................Clearing message instances.................");                                    
                    }
                    tobeRemove.append(execIdx);
                }
                
                execIdx = execIdx + 1;
            }

            for ele in tobeRemove {
                self.execCache.remove(at: ele);
            }
        }

        pub fun makeChallenge(challenger: Address, fromChain: String, msgID: UInt128, 
                                signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]) {
            let rawData = MessageProtocol.to_be_bytes_u128(msgID).concat(fromChain.utf8);

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: challenger, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              rawData: rawData,
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA3_256)) {
                panic("Signature verification failed!");
            } 
            
            for idx, ele in self.execCache {
                if (ele.verifiedMessage.messageCore.fromChain == fromChain) &&
                    (ele.verifiedMessage.messageCore.id == msgID) {
                    self.execCache[idx].makeChallenge(challenger);
                    break;    
                }
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

 