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
    tokenURL: String
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
          tokenURL: tokenURL
      );
    }
}