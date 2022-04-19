import SentMessageContract from 0xf53ab0e16337800f;
import CrossChain from 0xf53ab0e16337800f;

pub contract NFTCrossChain {

    init(){  
      self.initSentMessageVault();
     }

    pub event showSentMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String);
    pub event showReceviedMessage(messageId:Int, fromChain: String, sender: String, contractName: String, actionName: String, data: String);
 
    /**
      * Init send cross chain message
      */
    priv fun initSentMessageVault(){
      // create cross chain sent message resource
      let sentMessageVault <-SentMessageContract.createSentMessageVault();
      // save message as resource
      self.account.save(<-sentMessageVault, to: /storage/sentMessageVault);
      self.account.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault);
      // add acceptor link
      self.account.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault);

      // add message submitter
      let msgSubmitter <- SentMessageContract.createMessageSubmitter(); 
      self.account.save(<-msgSubmitter, to: /storage/msgSubmitter);
      self.account.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storage/msgSubmitter);
    }

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
      * Register current contract into cross chain contract
      */
    pub fun register():Bool{
      return CrossChain.registerContract(address: self.account.address);
    }
}
