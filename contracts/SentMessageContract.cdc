import MessageProtocol from 0x01

pub contract SentMessageContract{

    pub struct msgToSubmit{
        pub let toChain: String;
        pub let sqos: [MessageProtocol.SQoSItem];
        pub let contractName: String;
        pub let actionName: String;
        pub let data: MessageProtocol.MessagePayload;
        pub let callType: UInt8;
        pub let callback: String?;
        pub let commitment: [UInt8]?;
        pub let answer: [UInt8]?;

      init(toChain: String, sqos: [MessageProtocol.SQoSItem], 
            contractName: String, actionName: String, data: MessageProtocol.MessagePayload,
            callType: UInt8, callback: String?, oc: [UInt8]?, oa: [UInt8]?){
            self.toChain = toChain;
            self.sqos = sqos;
            self.contractName = contractName;
            self.actionName = actionName;
            self.data = data;
            self.callType = callType;
            self.callback = callback;
            self.commitment = oc;
            self.answer = oa;
      }
    }

    // Submitter's interface
    pub resource interface SubmitterFace{
        access(contract) fun getHookedContent(): msgToSubmit;
    }

    // Submitter.
    pub resource Submitter: SubmitterFace{
        priv var hookedContent: msgToSubmit?;
        // in resource `Submitter`
        // test field, add after remove
        // pub let id: UInt128;

        pub init(){
            self.hookedContent = nil;
            // in resource `Submitter`
            // self.id = 100;
        }

        // the `oSubmitterAddr` must be the owner of this resource, or else `Acceptor` will receive an invalid submit
        pub fun submitWithAuth(_ outContent: msgToSubmit, acceptorAddr: Address, alink: String, oSubmitterAddr: Address, slink: String){
            // make `set` and `clear` atomic
            self.setHookedContent(outContent);

            let pubAcct = getAccount(acceptorAddr);
            let linkPath = PublicPath(identifier: alink);
            // let linkPath = /public/acceptlink;
            let acceptorLink = pubAcct.getCapability<&{AcceptorFace}>(linkPath!);
            if let acceptorRef = acceptorLink.borrow(){
                acceptorRef.AcceptContent(submitterAddr: oSubmitterAddr, link: slink);
            }else{
                panic("Invalid acceptor!");
            }

            self.clearHookedContent();
        }

        // Implementation of interface `SubmitterFace`
        access(contract) fun getHookedContent(): msgToSubmit{
            return self.hookedContent!;
        }

        // private functions
        priv fun setHookedContent(_ outContent: msgToSubmit){
            self.hookedContent = outContent;
        }

        priv fun clearHookedContent(){
            self.hookedContent = nil;
        }
    }

    // Define message core
    pub struct SentMessageCore{
      pub let id: UInt128; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let signer: String; // signer of the message call, the same as sender in Flow
      pub let sqos: [MessageProtocol.SQoSItem];
      pub let content: {String: AnyStruct}; // message content
      pub let session: MessageProtocol.Session;

      init(id: UInt128, toChain: String, sender: String, signer: String, 
                    sqos: [MessageProtocol.SQoSItem], 
                    contractName: String, actionName: String, data: MessageProtocol.MessagePayload, 
                    session: MessageProtocol.Session){
        self.id = id;
        self.fromChain = "FLOW";
        self.toChain = toChain;
        self.sender = sender;
        self.signer = signer;
        self.sqos = sqos;
        self.content = {
          "contractName": contractName, // contract name of destination chain
          "actionName": actionName, // action name of contract
          "data": data // cross chain message data
        };
        self.session = session;
      }
    }

    // Interface is used for access control.
    pub resource interface SentMessageInterface{
        pub message: [SentMessageCore];

        pub fun getAllMessages():[SentMessageCore];
        
        pub fun getMessageById(mesasageId: Int): SentMessageCore;

        pub fun isOnline(): Bool;
    }

    // Acceptor's interface
    pub resource interface AcceptorFace{
        // `oid` is the test field, add after remove
        access(contract) fun AcceptContent(submitterAddr: Address, link: String);
    }

    // Define sent message vault
    pub resource SentMessageVault: SentMessageInterface, AcceptorFace{
        priv var sessionID: UInt128;
        pub let message: [SentMessageCore];
        priv var online: Bool;

        init(){
            self.message = [];
            self.sessionID = 0;
            self.online = true;
        }

        /**
          * add cross chain message to SentMessageVault
          * @param submitterAddr - the message submitter. get sender here
          * @param link - the `SubmitterFace` link
          */
        access(contract) fun AcceptContent(submitterAddr: Address, link: String){

            let pubAcct = getAccount(submitterAddr);
            let linkPath = PublicPath(identifier: link);
            // let linkPath = /public/submitlink;
            let submittorLink = pubAcct.getCapability<&{SubmitterFace}>(linkPath!);

            if let submittorRef = submittorLink.borrow(){
                let rst = submittorRef.getHookedContent();
                
                self.message.append(SentMessageCore(id: MessageProtocol.getNextMessageID(), 
                                                    toChain: rst.toChain, 
                                                    sender: submitterAddr.toString(), 
                                                    signer: submitterAddr.toString(),
                                                    sqos: rst.sqos,
                                                    contractName: rst.contractName, 
                                                    actionName: rst.actionName, 
                                                    data: rst.data,
                                                    session: MessageProtocol.Session(id: self.sessionID, type: rst.callType, callback: rst.callback, oc: rst.commitment, oa: rst.answer)));
                
                self.sessionID = self.sessionID + 1;

                // if (self.message.length > 10){
                //   self.message.removeFirst();
                // }

            }else{
                panic("Invalid submitter!");
            }
        }

        /**
          * Query sent cross chain messages
          */
        pub fun getAllMessages(): [SentMessageCore]{
          return self.message;
        }

        /**
          * Query sent cross chain messages by id
          * @param messageId - message id
          */
        pub fun getMessageById(mesasageId: Int): SentMessageCore{
            return self.message[mesasageId];
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
    }

    // Create recource to store sent message
    pub fun createSentMessageVault(): @SentMessageVault{
        return <- create SentMessageVault();
    }

    pub fun createMessageSubmitter(): @Submitter{
        return <- create Submitter();
    }

    // Query messages
    // **Notice:** 
    // * Currently routers off-chain will know the address of the account of `NFTCrossChain`.
    // * `SentMessageContract` contract will manage the `SentMessageVault` and a more convenient interface will publish in the future.
    // ***********
    pub fun QueryMessage(msgSender: Address, link: String): [SentMessageCore]{
      let pubLink = PublicPath(identifier: link);
      let senderRef = getAccount(msgSender).getCapability<&{SentMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
      return senderRef.getAllMessages();
    }
}