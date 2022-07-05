import MessageProtocol from 0xTheProtocolContractAddress
import IdentityVerification from 0x01

pub contract ReceivedMessageContract{

    // Define message core
    pub struct ReceivedMessageCore{
        pub let id: UInt128; // message id
        pub let fromChain: String; // FLOW, source chain name
        pub let toChain: String; // destination chain name
        pub let sender: String; // sender of cross chain message
        pub let sqos: MessageProtocol.SQoS;
        pub let content: AnyStruct; // message content
        pub let session: MessageProtocol.Session;
        pub let messageHash: String; // message hash value

        init(id: UInt128, fromChain: String, sender: String, sqos: MessageProtocol.SQoS, 
              contractName: String, actionName: String, data: MessageProtocol.MessagePayload,
              session: MessageProtocol.Session){
            self.id = id;
            self.fromChain = fromChain;
            self.toChain = "FLOW";
            self.sender = sender;
            self.sqos = sqos;
            self.content = {
              "contractName": contractName, // contract name of destination chain
              "actionName": actionName, // action name of contract
              "data": data // cross chain message data
            };
            self.session = session;

            // hash message info
            var originData: [UInt8] = id.toBigEndianBytes();
            originData = originData.concat(fromChain.utf8);
            originData = originData.concat(toChain.utf8);
            originData = originData.concat(sender.utf8);
            originData = originData.concat(sqos.toBytes());
            originData = originData.concat(contractName.utf8);
            originData = originData.concat(actionName.utf8);
            originData = originData.concat(data.toBytes());
            originData = originData.concat(session.toBytes());
            let digest = HashAlgorithm.SHA2_256.hash(originData);
            self.messageHash = String.encodeHex(digest);
        }

        pub fun getRecvMessageHash(): [UInt8] {
            return self.messageHash.decodeHex();
        }
    }

     // Interface is used for access control.
    pub resource interface ReceivedMessageInterface{
        pub message: [ReceivedMessageCache];

        pub fun getMessageById(messageId: Int):ReceivedMessageCache;

        pub fun getMessageCount(): Int;

        pub fun messageVerify(messageId: Int): Bool;

        pub fun isValidRecver(): Bool;
    }

    pub struct messageCopy {
        pub let messageInfo: ReceivedMessageCore;
        pub let submitters: [Address];
        pub var credibility: UInt128;

        init(om: ReceivedMessageCore) {
            self messageInfo = om;
            self.submitters = [];
            self.credibility = 0;
        }

        pub fun addSubmitter(submitter: Address) {
            self.submitters.append(submitter);
        }
    }

    // Define received message array
    pub struct ReceivedMessageCache{
        pub let msgInstance: {String, messageCopy};
        pub let msgID: UInt128;
        pub var msgCount: Int;

        init(id: UInt128){
            self.msgInstance = {};
            self.msgID = id;
            self.msgCount = 0;
        }

        pub fun insert(receivedMessageCore: ReceivedMessageCore, pubAddr: Address){
            // Add to related messageCopy
            if (self.msgInstance.containsKey(receivedMessageCore.messageHash)) {
                self.msgInstance[receivedMessageCore.messageHash].submitters.append(pubAddr);
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
    }

    // define resource to stores received cross chain message 
    pub resource ReceivedMessageVault: ReceivedMessageInterface{
        pub let message: {String, [ReceivedMessageCache]};
        pub let executableCount: Int;
        pub var completedID: UInt128;   //TODO: check this tommorow!

        init(){
          self.message = {};
          self.executableCount = 10;
          self.completedID = 0;
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
          // TODO
          /*
            * the submitter of the message should be verified
            * this can be done by the signature and public keys routers registered(`ReceivedMessageContract.registerRouter`)
          */

            // Verify the signature
            if (!IdentityVerification.basicVerify(pubAddr: pubAddr, 
                                              signatureAlgorithm: signatureAlgorithm,
                                              signature: signature,
                                              hashAlgorithm: HashAlgorithm.SHA2_256)) {
                panic("invalid recver address or `link`!")
                return false;
            }
            
            if (self.message.containsKey(recvMsg.fromChain)) {  
                let caches: &[ReceivedMessageCache] = &self.message[recvMsg.fromChain]! as &[ReceivedMessageCache];

                var found = false;
                for idx, ele in self.message[recvMsg.fromChain]! {
                    if (recvMsg.id == ele.msgID) {
                        self.message[recvMsg.fromChain]![idx].insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                        found = true;
                        break;
                    }
                }

                if ((!found) && (recvMsg.id > self.completedID)) {
                    // TODO: this strategy need to be checked!
                }

                if (recvMsg.id > caches[caches.length - 1].msgID){
                    let mcache = ReceivedMessageCache(recvMsg.id);
                    mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                    caches.append(mcache);
                } else {
                    for idx, ele in self.message[recvMsg.fromChain]! {
                        if (recvMsg.id == ele.msgID) {
                            self.message[recvMsg.fromChain]![idx].insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                            break;
                        }
                    }
                }
            } else {
                let mcache = ReceivedMessageCache(recvMsg.id);
                mcache.insert(receivedMessageCore: recvMsg, pubAddr: pubAddr);
                self.message[recvMsg.fromChain] = [mcache];
            }
        }

        /**
          * Query received cross chain messages by message id
          * @param messageId - message id
          */
        pub fun getMessageById(messageId: Int):ReceivedMessageArray{
          return self.message[messageId];
        }

        /**
          * Query count of received cross chain messages
          */
        pub fun getMessageCount(): Int{
          return self.message.length;
        }

        /**
          * Make sure that every message saved in ReceivedMessageArray is consistent
          * @param messageId - message id
          */
        pub fun messageVerify(messageId: Int): Bool{
          // TODO
          return true;
        }

        pub fun isValidRecver(): Bool {
          return true;
        }

        /**
          * Query first executable message, the unrepeated messages are more than executableCount.
          */
        pub fun getExecutableMessage():Int{
          // TODO
          return 0;
        }

        /**
          * Query next message id
          */
        pub fun getNextPortingMessageId(): Int{
          // TODO
          return self.message.length;
        }

        /**
          * Called from `messageVerify` to get the credibilities of validators to take weighted aggregation verification of messages
          */
        pub fun getValidatorCredibility(){
          // TODO
        }

        /**
          * Called from `messageVerify`. Update validator credibility by node behaviors after message verification.
          */
        pub fun updateValidatorCredibility(){
          // TODO
        }

        /**
          * Set the value of the credibility of the newly added validator
          * @param initValue - init value of credibility
          */
        pub fun setInitialCredibility(initValue: Int){
          // TODO
        }
    }

    // Create recource to store received message
    pub fun createReceivedMessageVault():@ReceivedMessageVault{
      // TODO
      /**
        * record the resouces' `public/link`
        */
      return <- create ReceivedMessageVault();
    }

     /**
       * The interface of the register for off-chain routers
       * the common sign-verification mechanism or authority call-back submittion mechanis
       */
     pub fun registerRouter(){
          // TODO
     }

     /**
       * The interface of the unregister for off-chain routers
       */
     pub fun unregisterRouter(){

     }
}

