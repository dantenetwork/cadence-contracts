import SentMessageContract from 0xf8d6e0586b0a20c7;
import NonFungibleToken from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;
import NFTCrossChain from 0xf8d6e0586b0a20c7;
import MessageProtocol from 0xf8d6e0586b0a20c7;

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(
    recipient: Address,
    name: String,
    description: String,
    thumbnail: String,
    owner: String,
    commitment: String
) {
    let signer: AuthAccount;
    prepare(signer: AuthAccount){
      self.signer = signer;
    }
    
    execute {
      // borrow a reference to the NFTMinter resource in storage
      let minter = self.signer.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)
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
      let SQoSItem = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Identity, value: "");
      let contractName = "0x263037FdFa433828fCBF97B87200A0E0b8d68C5f";
      let actionName = "mintTo";
      let callType: UInt8 = 1;
      let callback = "";
      let commitment = commitment;
      let answer = "";

      let data = MessageProtocol.MessagePayload();
      let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: owner);
      data.addItem(item: ownerItem);

      // send cross chain message
      // borrow resource from storage
      // let messageReference = self.account.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault);
      // messageReference!.addMessage(toChain: toChain, sender:self.account.address.toString(), contractName:contractName, actionName:actionName, data:data);

      let msgSubmitterRef = self.signer.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter);
      let msg = SentMessageContract.msgToSubmit(toChain: toChain, sqos: [SQoSItem], contractName: contractName, actionName: actionName, data: data, callType: callType, callback: callback, commitment: commitment, answer: answer);
      msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: self.signer.address, alink: "acceptorFace", oSubmitterAddr: self.signer.address, slink: "msgSubmitter");
    
    }
}