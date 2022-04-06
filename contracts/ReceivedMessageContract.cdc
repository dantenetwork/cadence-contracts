pub contract ReceivedMessageContract{

    // Define message core
    pub struct ReceivedMessageCore{
      pub let id: Int; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let content: AnyStruct; // message content

      init(id: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String){
        self.id = id;
        self.fromChain = fromChain;
        self.toChain = "FLOW";
        self.sender = sender;
        self.content = {
          "contractName": contractName, // contract name of destination chain
          "actionName": actionName, // action name of contract
          "data": data // cross chain message data
        };
      }
    }

     // Interface is used for access control.
    pub resource interface ReceivedMessageInterface{
        pub message: [ReceivedMessageArray];

        pub fun addMessage(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);

        pub fun getMessageById(messageId: Int):ReceivedMessageArray;

        pub fun getLength(): Int;
    }

    // Define received message array
    pub struct ReceivedMessageArray{
      pub let message: [ReceivedMessageCore];

      init(receivedMessageCore: ReceivedMessageCore){
        self.message = [receivedMessageCore];
      }

      pub fun append(receivedMessageCore: ReceivedMessageCore){
        self.message.append(receivedMessageCore);
      }
    }

    // define resource to stores received cross chain message 
    pub resource ReceivedMessageVault: ReceivedMessageInterface{
        pub let message: [ReceivedMessageArray];

        init(){
          self.message = [];
        }

        pub fun addMessage(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String){
          let receivedMessageCore = ReceivedMessageCore(id:messageId, fromChain:fromChain, sender:sender, contractName:contractName, actionName:actionName, data:data);
          if(self.message.length < messageId + 1){
            // message id not exists
            let receivedMessageArray = ReceivedMessageArray(receivedMessageCore:receivedMessageCore);
            self.message.append(receivedMessageArray);
          }else{
            // message id exists
            var receivedMessageArray = self.message[messageId];
            receivedMessageArray.append(receivedMessageCore:receivedMessageCore);
            self.message[messageId] = receivedMessageArray;
          }
        }

        // get message by id
        pub fun getMessageById(messageId: Int):ReceivedMessageArray{
          return self.message[messageId];
        }

        // get message length
        pub fun getLength(): Int{
          return self.message.length;
        }
    }

    // Create recource to store received message
    pub fun createReceivedMessageVault():@ReceivedMessageVault{
      return <- create ReceivedMessageVault();
    }
}

