import SentMessageContract from 0xf53ab0e16337800f;
import ReceivedMessageContract from 0xf53ab0e16337800f;
import CrossChain from 0xf53ab0e16337800f;
import ExampleNFT from 0xf53ab0e16337800f;
import NonFungibleToken from 0xf53ab0e16337800f;

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
      * Mint Example NFT
      */
    access(account) fun mintNFT(recipient: Address,name: String,description: String,thumbnail: String):Bool{
      // borrow a reference to the NFTMinter resource in storage
        let minter = self.account.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter");

      // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(recipient)
            .getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection");

        // Mint the NFT and deposit it to the recipient's collection
        minter.mintNFT(
            recipient: receiver,
            name: name,
            description: description,
            thumbnail: thumbnail,
        );

        let toChain = "Ethereum";
        let contractName = "0x7e13e8f8934dA6a4EF903766D42D98d5b16A6761";
        let actionName = "mintTo";
        let data = "0xED911Ca21fDba9dB5f3B61b014B96A9Fab665Ff9";

        let message = SentMessageContract.msgToSubmit(toChain: toChain, contractName: contractName, actionName: actionName, data: data);

        return self.sendCrossChainMessage(toChain: message.toChain, contractName: message.contractName, actionName: message.actionName, data: message.data);
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

      let msgSubmitterRef = self.account.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter);
      let msg = SentMessageContract.msgToSubmit(toChain: toChain, contractName: contractName, actionName: actionName, data: data);
      msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: self.account.address, alink: "acceptorFace", oSubmitterAddr: self.account.address, slink: "msgSubmitter");

      // print log
      emit showSentMessage(toChain: toChain, sender: self.account.address.toString(), contractName: contractName, actionName: actionName, data:data);
      return true;
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
