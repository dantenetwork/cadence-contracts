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
        pub msg: [SentMessageCore];

        pub fun getMsg():[SentMessageCore];
        
        pub fun getFirstMsg(): SentMessageCore;
    }

    // No one else can access `addMsg` if only publishes the link with `SentMessageInterface`. See `messageContractVisit` and `messageTrans` for detail
    pub resource SentMessage: SentMessageInterface{
        pub let msg: [SentMessageCore];

        init(){
            self.msg = [];
        }

        pub fun addMsg(toChain: String, sender: String, contractName: String, actionName: String, data: String){
            self.msg.append(SentMessageCore(id:self.msg.length, toChain:toChain, sender:sender, contractName:contractName, actionName:actionName, data:data));

            if (self.msg.length > 10){
                self.msg.removeFirst();
            }
        }

        pub fun getMsg():[SentMessageCore]{
          return self.msg;
        }

        pub fun getFirstMsg(): SentMessageCore{
            return self.msg[0];
        }
    }

    // Create recource to store sent message
    pub fun createSentMessage(): @SentMessage{
        return <- create SentMessage();
    }
}