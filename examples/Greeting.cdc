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
      let receivedMessageVault <-ReceivedMessageContract.createReceivedMessageVault();
      // save message as resource
      self.account.save(<-receivedMessageVault, to: /storage/receivedMessageVault);
      self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault, target: /storage/receivedMessageVault);
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
      let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      messageReference!.addMessage(toChain: toChain, sender:self.account.address.toString(), contractName:contractName, actionName:actionName, data:data);

      // print log
      emit showSentMessage(toChain: toChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
    }

    /**
      * Query sent cross chain messages
      */
    pub fun querySentMessageVault(): [SentMessageContract.SentMessageCore]{
      let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      return messageReference!.getAllMessages();
    }

    /**
      * Query sent cross chain messages by id
      * @param messageId - message id
      */
    pub fun querySentMessageById(mesasageId: Int): SentMessageContract.SentMessageCore{
      let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      return messageReference!.getMessageById(mesasageId: mesasageId);
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
      let messageReference = self.account.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault);

      // add message into received messages
      messageReference!.addMessage(messageId: messageId, fromChain: fromChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data: data);

      // print log
      emit showReceviedMessage(messageId: messageId, fromChain: fromChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
    }

    /**
      * Query recevied cross chain messages by message id
      * @param messageId - message id
      */
    pub fun queryReceivedMessageVaultById(messageId: Int):ReceivedMessageContract.ReceivedMessageArray{
      let messageReference = self.account.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault);
      return messageReference!.getMessageById(messageId: messageId);
    }

    /**
      * Query count of recevied cross chain messages
      */
    pub fun getReceivedMessageVaultLength(): Int{
      let messageReference = self.account.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault);
      return messageReference!.getLength();
    }

    /**
      * Register current contract into cross chain contract
      */
    pub fun register():Bool{
      return CrossChain.registerContract(address: self.account.address);
    }
}
