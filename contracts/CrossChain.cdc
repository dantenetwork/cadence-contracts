import CrossChainMessage from 0x01;
pub contract CrossChain {
    // Define message
    pub struct Message{
      pub let id: Int; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let content: AnyStruct; // message content

      init(id: Int, fromChain: String, toChain: String, sender: String, contractName: String, actionName: String, data: String){
        self.id=id;
        self.fromChain=fromChain;
        self.toChain=toChain;
        self.sender=sender;
        self.content={
          "contractName": contractName, // contract name of destination chain
          "actionName": actionName,// action name of contract
          "data": data// cross chain message data
        };
      }

    }

    pub var messageRecord:[Message]; // stores all cross chain messages
    pub let fromChain: String; // FLOW, source chain name

    // init cross chain
    init(){
        self.messageRecord = [];
        self.fromChain = "FLOW";
    }

    
    pub fun sendMessage(address: Address, toChain: String, contractName: String, actionName: String): Bool{
        // access account 
        let sender = getAccount(address);
        let messageCapability = sender.getCapability<&{CrossChainMessage.MessageInterface}>(/public/crossChainMessage);
        let messageReference = messageCapability.borrow()!;
        
        // append cross chain message into record
        let message = Message(id: self.messageRecord.length, fromChain:self.fromChain, toChain: toChain, sender: sender.address.toString(), contractName: contractName, actionName: actionName, data:messageReference.msg);
        self.messageRecord.append(message);
        return true;
    }

    // Get message by index
    pub fun queryMessageByIndex(index:Int):Message{
        return self.messageRecord[index];
    }

    // Query last message
    pub fun queryLastMessage():Message{
        return self.messageRecord[self.messageRecord.length-1];
    }

    // Get messaget count
    pub fun queryMessageCount():Int{
      return self.messageRecord.length;
    }
}