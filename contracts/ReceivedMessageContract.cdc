pub contract ReceivedMessageContract{

    // Define message core
    pub struct ReceivedMessageCore{
      pub let id: Int; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let content: AnyStruct; // message content
      pub let messageHash: String; // message hash value

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

        // hash message info
        var originData: [UInt8] = id.toBigEndianBytes();
        originData = originData.concat(fromChain.decodeHex());
        originData = originData.concat(sender.decodeHex());
        originData = originData.concat(contractName.decodeHex());
        originData = originData.concat(actionName.decodeHex());
        originData = originData.concat(data.decodeHex());
        let digest = HashAlgorithm.SHA2_256.hash(originData);
        self.messageHash = String.encodeHex(digest);
      }
    }

     // Interface is used for access control.
    pub resource interface ReceivedMessageInterface{
        pub message: [ReceivedMessageArray];

        pub fun addMessage(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);

        pub fun getMessageById(messageId: Int):ReceivedMessageArray;

        pub fun getMessageCount(): Int;

        pub fun messageVerify(messageId: Int): Bool;
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

      pub fun getMessageCount(): Int{
        return self.message.length;
      }
    }

    // define resource to stores received cross chain message 
    pub resource ReceivedMessageVault: ReceivedMessageInterface{
        pub let message: [ReceivedMessageArray];
        pub let executableCount: Int;

        init(){
          self.message = [];
          self.executableCount = 10;
        }

        /**
          * add cross chain message to ReceivedMessageVault
          * @param messageId - message id
          * @param fromChain - source chain
          * @param contractName - contract name of source chain
          * @param actionName - action name of source contract
          * @param data - contract execute data
          */
        pub fun addMessage(messageId: Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String){
          let receivedMessageCore = ReceivedMessageCore(id:messageId, fromChain:fromChain, sender:sender, contractName:contractName, actionName:actionName, data:data);
          if(self.message.length < messageId + 1){
            // message id not exists
            let receivedMessageArray = ReceivedMessageArray(receivedMessageCore:receivedMessageCore);
            self.message.append(receivedMessageArray);
          }else{
            // message id exists
            var receivedMessageArray = self.message[messageId];
            if(receivedMessageArray.getMessageCount() < self.executableCount){
              receivedMessageArray.append(receivedMessageCore:receivedMessageCore);
              self.message[messageId] = receivedMessageArray;
            }
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
    }

    // Create recource to store received message
    pub fun createReceivedMessageVault():@ReceivedMessageVault{
      return <- create ReceivedMessageVault();
    }
}

