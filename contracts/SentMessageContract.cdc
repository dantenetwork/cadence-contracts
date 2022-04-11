pub contract SentMessageContract{

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

    // Define sent message vault
    pub resource SentMessageVault: SentMessageInterface{
        pub let message: [SentMessageCore];

        init(){
            self.message = [];
        }

        /**
          * add cross chain message to SentMessageVault
          * @param toChain - destination chain
          * @param sender - message sender
          * @param contractName - contract name of destination chain
          * @param actionName - action name of destination contract
          * @param data - contract execute data
          */
        pub fun addMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String){
            self.message.append(SentMessageCore(id: self.message.length, toChain: toChain, sender: sender, contractName: contractName, actionName: actionName, data: data));

            if (self.message.length > 10){
                self.message.removeFirst();
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
    }

    // Create recource to store sent message
    pub fun createSentMessageVault(): @SentMessageVault{
        return <- create SentMessageVault();
    }
}