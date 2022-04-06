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
        pub msg: [ReceivedMessageArray];

        pub fun addMsg(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);
    }

    // Define received message array
    pub struct ReceivedMessageArray{
      pub let msg: [ReceivedMessageCore];

      init(receivedMessageCore: ReceivedMessageCore){
        self.msg = [receivedMessageCore];
      }

      pub fun append(receivedMessageCore: ReceivedMessageCore){
        self.msg.append(receivedMessageCore);
      }
    }

    pub resource ReceivedMessageVault: ReceivedMessageInterface{
        pub let msg: [ReceivedMessageArray];

        init(){
          self.msg = [];
        }

        pub fun addMsg(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String){
          let receivedMessageCore = ReceivedMessageCore(id:messageId, fromChain:fromChain, sender:sender, contractName:contractName, actionName:actionName, data:data);
          if(self.msg.length < messageId + 1){
            // message id not exists
            let receivedMessageArray = ReceivedMessageArray(receivedMessageCore:receivedMessageCore);
            self.msg.append(receivedMessageArray);
          }else{
            // message id exists
            var receivedMessageArray = self.msg[messageId];
            receivedMessageArray.append(receivedMessageCore:receivedMessageCore);
            self.msg[messageId] = receivedMessageArray;
          }
        }

        // get all messages
        pub fun getMsg(messageId: Int):ReceivedMessageArray{
          return self.msg[index];
        }

        // get message length
        pub fun getLength(): Int{
          return self.msg.length;
        }
    }

    // Create recource to store received message
    pub fun createReceivedMessageVault():@ReceivedMessageVault{
      return <- create ReceivedMessageVault();
    }
}

