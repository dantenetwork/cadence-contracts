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
        pub fun isOnline(): Bool;
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
        pub let messageHash: String; // message hash value

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
        pub let message: {String: [ReceivedMessageCache]};
        pub let executableCount: Int;
        // pub var completedID: {String: UInt128};   
        priv var online: Bool;
        priv var defaultCopyCount: Int;
        // TODO: context

        init(){
            self.message = {};
            self.executableCount = 10;
            //self.completedID = {};
            self.online = true;
            self.defaultCopyCount = 1; // TODO defaultCopyCount = 1, debug only
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
                
                if (!found) {
                    var completedID: UInt128 = 0;
                    if let cplID = ReceivedMessageContract.completedID[recvMsg.fromChain] {
                        completedID = cplID;
                    } else {
                        ReceivedMessageContract.completedID[recvMsg.fromChain] = 0;
                    }

                    if (recvMsg.id > completedID) {
                        // TODO: this strategy need to be checked!
                        let mcache = ReceivedMessageCache(id: recvMsg.id);
                        mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                        caches.append(mcache);

                        cacheIdx = caches.length - 1;
                    } else {
                        panic("Invalid `recvMsg` ID!");
                    }
                }

            } else {
                var completedID: UInt128 = 0;
                if let cplID = ReceivedMessageContract.completedID[recvMsg.fromChain] {
                    completedID = cplID;
                } else {
                    ReceivedMessageContract.completedID[recvMsg.fromChain] = 0;
                }

                if recvMsg.id > completedID {
                    let mcache = ReceivedMessageCache(id: recvMsg.id);
                    mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                    self.message[recvMsg.fromChain] = [mcache];
                    cacheIdx = 0;
                } else {
                    panic("Invalid `recvMsg` ID!");
                }
            }

            if (cacheIdx >= 0) {
                if (self.message[recvMsg.fromChain]![cacheIdx].getMessageCount() >= self.defaultCopyCount) {
                    // TODO: do verification
                    let msgVerified = self.messageVerify(messageCache: self.message[recvMsg.fromChain]![cacheIdx]);
                    
                    if msgVerified == nil {
                        return;
                    }

                    let msgContent = msgVerified!.content;

                    // TODO: call destination
                    let pubLink = PublicPath(identifier: msgContent.link);
                    if (nil == pubLink)
                    {
                        self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                        panic("invalid `link` path!");
                    }

                    // let calleeRef = getAccount(address).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
                    let calleeRef = getAccount(msgContent.accountAddress).getCapability<&{ReceivedMessageContract.Callee}>(pubLink!).borrow();
                    if (nil == calleeRef){
                        self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                        panic("invalid callee address or `link`!");
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

                    self.message[recvMsg.fromChain]!.remove(at: cacheIdx);
                    // if (self.completedID[recvMsg.fromChain]! < recvMsg.id) {
                    //     self.completedID[recvMsg.fromChain] = recvMsg.id;
                    // }

                    if let cplID = ReceivedMessageContract.completedID[recvMsg.fromChain] {
                        if (cplID < recvMsg.id) {
                            ReceivedMessageContract.completedID[recvMsg.fromChain] = recvMsg.id;
                        }
                    } else {
                        ReceivedMessageContract.completedID[recvMsg.fromChain] = recvMsg.id;
                    }
                }
            }
        }
 
        pub fun getCompleteID(): {String: UInt128}{
            return ReceivedMessageContract.completedID;
        }

        pub fun getNextMessageID(submitterAddr: Address): {String: UInt128} {
            let nextIDs = ReceivedMessageContract.completedID;

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

        // Move to an independent cdc
        /**
          * Make sure that every message saved in ReceivedMessageArray is consistent
          * @param messageId - message id
          */
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
          * Called from `messageVerify` to get the credibilities of validators to take weighted aggregation verification of messages
          */
        // pub fun getValidatorCredibility(){
        //     // TODO
        // }

        /**
          * Called from `messageVerify`. Update validator credibility by node behaviors after message verification.
          */
        // pub fun updateValidatorCredibility(){
        //     // TODO
        // }

        /**
          * Set the value of the credibility of the newly added validator
          * @param initValue - init value of credibility
          */
        // pub fun setInitialCredibility(initValue: Int){
        //     // TODO
        // }
    }

    // Temporarily, verification threshold is setted to be 0.7 when contract deployed
    // This will be moved to Resource `ReceivedMessageVault` when developing `SQoS` features
    // This value must be larger than 0.5
    pub let vfThreshold: UFix64;

    access(contract) let completedID: {String: UInt128}; 

    init() {
        self.vfThreshold = 0.7;
        self.completedID = {};
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

    pub fun getRecverRef(recverAddress: Address, link: String): &{ReceivedMessageContract.ReceivedMessageInterface}? {
        let pubLink = PublicPath(identifier: link);
        let recver = getAccount(recverAddress).getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(pubLink!);
        return recver.borrow();
    }

    // Temporary test
    pub fun testSettlementCall() {
        SettlementContract.workingNodesTrail(honest: [], evil: [], exception: {});
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
     /**
       * The interface of the register for off-chain routers
       * the common sign-verification mechanism or authority call-back submittion mechanis
       */
    //  pub fun registerRouter(){
    //     // TODO
    //  }

    //  /**
    //    * The interface of the unregister for off-chain routers
    //    */
    //  pub fun unregisterRouter(){

    //  }
}

 