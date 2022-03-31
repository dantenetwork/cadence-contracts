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

        pub fun getMsg():[ReceivedMessageArray];
        
        pub fun getFirstMsg(): ReceivedMessageArray;
    }

    // Define receive message core
    pub struct ReceivedMessageArray{
      pub let msg: [ReceivedMessageCore];

      init(receivedMessageCore: ReceivedMessageCore){
        self.msg = [receivedMessageCore];
      }

      pub fun append(receivedMessageCore: ReceivedMessageCore){
        self.msg.append(receivedMessageCore);
      }
    }

    // No one else can access `addMsg` if only publishes the link with `SentMessageInterface`. See `messageContractVisit` and `messageTrans` for detail
    pub resource ReceivedMessage: ReceivedMessageInterface{
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

        pub fun getMsg():[ReceivedMessageArray]{
          return self.msg;
        }

        pub fun getFirstMsg(): ReceivedMessageArray{
            return self.msg[0];
        }
    }

    // Create recource to store received message
    pub fun createReceivedMessage():@ReceivedMessage{
      return <- create ReceivedMessage();
    }
}

