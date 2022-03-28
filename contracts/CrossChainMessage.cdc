pub contract CrossChainMessage{

    // Define message
    pub struct MessageCore{
      pub let id: Int; // message id
      pub let fromChain: String; // FLOW, source chain name
      pub let toChain: String; // destination chain name
      pub let sender: String; // sender of cross chain message
      pub let content: AnyStruct; // message content

      init(id: Int, toChain: String, sender: String, contractName: String, actionName: String, data: String){
        self.id=id;
        self.fromChain="FLOW";
        self.toChain=toChain;
        self.sender=sender;
        self.content={
          "contractName": contractName, // contract name of destination chain
          "actionName": actionName,// action name of contract
          "data": data// cross chain message data
        };
      }

    }

    // Interface is used for access control.
    pub resource interface BaseMsg{
        pub msg: [MessageCore];

        pub fun getMsg():[MessageCore];
        
        pub fun getFirstMsg(): MessageCore;
    }

    // No one else can access `addMsg` if only publishes the link with `BaseMsg`. See `messageContractVisit` and `messageTrans` for detail
    pub resource Message: BaseMsg{
        pub let msg: [MessageCore];

        init(){
            self.msg = [];
        }

        pub fun addMsg(toChain: String,sender: String,contractName: String,actionName: String,data: String){
            self.msg.append(MessageCore(id:self.msg.length,toChain:toChain,sender:sender,contractName:contractName,actionName:actionName,data:data));

            if (self.msg.length > 10){
                self.msg.removeFirst();
            }
        }

        pub fun getMsg():[MessageCore]{
          return self.msg;
        }

        pub fun getFirstMsg(): MessageCore{
            return self.msg[0]
        }
    }

    pub fun createMessage(): @Message{
        return <- create Message()
    }
}