pub contract SentMessageContract{

    pub struct msgToSubmit{
      pub let toChain: String;
      pub let contractName: String;
      pub let actionName: String;
      pub let data: String;

      init(toChain: String, contractName: String, actionName: String, data: String){
          self.toChain = toChain;
          self.contractName = contractName;
          self.actionName = actionName;
          self.data = data;
      }
    }

    // Submitter's interface
    pub resource interface SubmitterFace{
        access(contract) fun getHookedContent(): msgToSubmit;
    }

    // Submitter
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
            let acceptorLink = pubAcct.getCapability<&{SubmitAuthor.AcceptorFace}>(linkPath!);
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
      pub let id: Int; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let content: AnyStruct; // message content

      init(id: Int, toChain: String, sender: String, contractName: String, actionName: String, data: String){
        self.id = id;
        self.fromChain = "FLOW";
        self.toChain = toChain;
        self.sender = sender;
        self.content = {
          "contractName": contractName, // contract name of destination chain
          "actionName": actionName, // action name of contract
          "data": data // cross chain message data
        };
      }
    }

    // Interface is used for access control.
    pub resource interface SentMessageInterface{
        pub message: [SentMessageCore];

        pub fun getAllMessages():[SentMessageCore];
        
        pub fun getMessageById(mesasageId: Int): SentMessageCore;
    }

    // Acceptor's interface
    pub resource interface AcceptorFace{
        // `oid` is the test field, add after remove
        access(contract) fun AcceptContent(submitterAddr: Address, link: String);
    }

    // Define sent message vault
    pub resource SentMessageVault: SentMessageInterface, AcceptorFace{
        pub let message: [SentMessageCore];

        init(){
            self.message = [];
        }

        /**
          * add cross chain message to SentMessageVault
          * @param submitterAddr - the message submitter. get sender here
          * @param link - the `SubmitterFace` link
          */
        access(contract) fun AcceptContent(submitterAddr: Address, link: String){

            emit uuidEvent(type: "Acceptor", uuuuid: self.uuid);

            let pubAcct = getAccount(submitterAddr);
            let linkPath = PublicPath(identifier: link);
            // let linkPath = /public/submitlink;
            let submittorLink = pubAcct.getCapability<&{SubmitterFace}>(linkPath!);

            if let submittorRef = submittorLink.borrow(){
                let rst = submittorRef.getHookedContent();
                
                self.message.append(SentMessageCore(id: self.message.length, 
                                                    toChain: rst.toChain, 
                                                    sender: submitterAddr.toString(), 
                                                    contractName: rst.contractName, 
                                                    actionName: rst.actionName, 
                                                    data: rst.data));
                
                if (self.message.length > 10){
                  self.message.removeFirst();
                }

            }else{
                panic("Invalid submitter!");
            }
        }

        /**
          * add cross chain message to SentMessageVault
          * @param toChain - destination chain
          * @param sender - message sender
          * @param contractName - contract name of destination chain
          * @param actionName - action name of destination contract
          * @param data - contract execute data
          */
        // deprecated
        // pub fun addMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String){
        //     self.message.append(SentMessageCore(id: self.message.length, toChain: toChain, sender: sender, contractName: contractName, actionName: actionName, data: data));

        //     if (self.message.length > 10){
        //         self.message.removeFirst();
        //     }
        // }

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
      let senderLink = getAccount(msgSender).getCapability<&{SentMessageInterface}>(pubLink!);
      if let senderRef = senderLink.borrow(){
          return senderRef.getAllMessages();
      } else{
          panic("invalid sender address or `link`!");
      }
    }

    // interface todo:
    // create
    // pub fun createSentMessageVault(msgSender: Address, link: String): @SentMessageVault{
    //     // record the senders
    //     return <- create SentMessageVault();
    // }

    // query senders
    // pub fun querySenders(): [(Address, String)]{

    // }
}