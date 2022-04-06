import SentMessageContract from 0xf8d6e0586b0a20c7;
import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub contract Greeting {

    init(){  
      // create cross chain sent message resource
      let sentMessageVault <-SentMessageContract.createSentMessageVault();
      // save message as resource
      self.account.save(<-sentMessageVault, to: /storage/sentMessageVault);
      self.account.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault);


      // create cross chain reveived message resource
      let receivedMessageResource <-ReceivedMessageContract.createReceivedMessage();
      // save message as resource
      self.account.save(<-receivedMessageResource, to: /storage/crossChainReceivedMessage);
      self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/crossChainReceivedMessage, target: /storage/crossChainReceivedMessage);
    }

    pub event showSentMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String);
    pub event showReceviedMessage(messageId:Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);

    /**
      * Send cross chain message
      * @param toChain - destination chain
      * @param contractName - contract name of destination chain
      * @param actionName - action name of destination contract
      * @param data - contract execute data
      */
    pub fun sendCrossChainMessage(toChain: String, contractName: String, actionName: String, data: String): Bool{
      // borrow resource from storage
      let msgRef = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      msgRef!.addMsg(toChain: toChain, sender:self.account.address.toString(), contractName:contractName, actionName:actionName, data:data);

      // destroy cross chain message resource
      // destroy resource;

      // print log
      emit showSentMessage(toChain: toChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
    }

    /**
      * Query cross chain sent messages
      */
    pub fun querySentMessageVault(): [SentMessageContract.SentMessageCore]{
      let msgRef = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      return msgRef!.getMsg();
    }

    /**
      * Received message from other chains
      * @param messageId - message id
      * @param fromChain - source chain
      * @param contractName - contract name of source chain
      * @param actionName - action name of source contract
      * @param data - contract execute data
      */
    pub fun receiveCrossChainMessage(messageId: Int, fromChain: String, contractName: String, actionName: String, data: String): Bool{
      // borrow resource from storage
      let msgRef = self.account.borrow<&ReceivedMessageContract.ReceivedMessage>(from: /storage/crossChainReceivedMessage);

      // add message into received messages
      msgRef!.addMsg(messageId: messageId, fromChain: fromChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data: data);

      // print log
      emit showReceviedMessage(messageId: messageId, fromChain: fromChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
    }

    /**
      * Query all cross chain recevied messages
      */
    pub fun queryCrossChainReceivedMessage():[ReceivedMessageContract.ReceivedMessageArray]{
      let msgRef = self.account.borrow<&ReceivedMessageContract.ReceivedMessage>(from: /storage/crossChainReceivedMessage);
      return msgRef!.getMsg();
    }

    pub fun getReceivedMessageLength(): Int{
      let msgRef = self.account.borrow<&ReceivedMessageContract.ReceivedMessage>(from: /storage/crossChainReceivedMessage);
      return msgRef!.getLength();
    }

    /**
      * Register current contract into cross chain contract
      */
    pub fun register():Bool{
      return CrossChain.register(address: self.account.address);
    }
}
