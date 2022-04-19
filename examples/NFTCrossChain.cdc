import SentMessageContract from 0xf53ab0e16337800f;
import ReceivedMessageContract from 0xf53ab0e16337800f;
import CrossChain from 0xf53ab0e16337800f;

pub contract NFTCrossChain {

    init(){  
      self.initSentMessageVault();
      self.initReceivedMessageVault();
    }

    pub event showSentMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String);
    pub event showReceviedMessage(messageId:Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);

    /**
      * Init send cross chain message
      */
    pub fun initSentMessageVault(){
      // create cross chain sent message resource
      let sentMessageVault <-SentMessageContract.createSentMessageVault();
      // save message as resource
      self.account.save(<-sentMessageVault, to: /storage/sentMessageVault);
      self.account.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault);
      // add acceptor link
      self.account.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault);

      // add message submitter
      let msgSubmitter <- SentMessageContract.createMessageSubmitter(); 
      self.account.save(<-msgSubmitter, to: /storate/msgSubmitter);
      self.account.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storate/msgSubmitter);

      // add Example NFT
      // add mint interface(  access(account)  )
      // send message in mint function
    }

    /**
      * Init received cross chain message
      */
    pub fun initReceivedMessageVault(){
      // create cross chain reveived message resource
      let receivedMessageVault <-ReceivedMessageContract.createReceivedMessageVault();
      // save message as resource
      self.account.save(<-receivedMessageVault, to: /storage/receivedMessageVault);
      self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault, target: /storage/receivedMessageVault);
    }

    /**
      * Send cross chain message
      * @param toChain - destination chain
      * @param contractName - contract name of destination chain
      * @param actionName - action name of destination contract
      * @param data - contract execute data
      */
    priv fun sendCrossChainMessage(toChain: String, contractName: String, actionName: String, data: String): Bool{
      // borrow resource from storage
      // let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      // messageReference!.addMessage(toChain: toChain, sender:self.account.address.toString(), contractName:contractName, actionName:actionName, data:data);

      let msgSubmitterRef = self.account.borrow<&{SentMessageContract.Submitter}>(from: /storage/msgSubmitter);
      let msg = SentMessageContract.msgToSubmit(toChain: toChain, contractName: contractName, actionName: actionName, data: data);
      msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: self.account.address, alink: "acceptorFace", oSubmitterAddr: self.account.address, slink: "msgSubmitter");

      // print log
      emit showSentMessage(toChain: toChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
    }

    /**
      * Query sent cross chain messages
      */
    // pub fun querySentMessageVault(): [SentMessageContract.SentMessageCore]{
    //   let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
    //   return messageReference!.getAllMessages();
    // }

    /**
      * reset sent message vault
      * this function is just for test
      */
    pub fun resetSentMessageVault(): Bool{
      // destroy sent message vault
      let sentMessageVault <- self.account.load<@SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      destroy sentMessageVault;
      self.initSentMessageVault();
      return true;
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
    pub fun getReceivedMessageVaultCount(): Int{
      let messageReference = self.account.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault);
      return messageReference!.getMessageCount();
    }

    /**
      * Register current contract into cross chain contract
      */
    pub fun register():Bool{
      return CrossChain.registerContract(address: self.account.address);
    }
}
