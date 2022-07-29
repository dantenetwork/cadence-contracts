import ExampleNFT from 0xf8d6e0586b0a20c7;
import NonFungibleToken from 0xf8d6e0586b0a20c7;
import MetadataViews from 0xf8d6e0586b0a20c7;
import Locker from 0x01cf0e2f2f715450;

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(
    id: UInt64,
    owner: String,
    hashValue: String
) {
    let signer: AuthAccount;
    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @NonFungibleToken.NFT;
    let tokenURL: String;
	
    prepare(signer: AuthAccount) {
        self.signer = signer;
        // Borrow a reference from the stored collection
        let collectionRef = signer.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        let nft = collectionRef.borrowExampleNFT(id: id)!

         // Get the basic display information for this NFT
        let view = nft.resolveView(Type<MetadataViews.Display>())!

        let display = view as! MetadataViews.Display
        self.tokenURL = display.tokenURL

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: id)
    }

    execute {
        Locker.sendCrossChainMessagge(transferToken: <-self.transferToken, signerAddress:self.signer.address, id: id, owner: owner, hashValue: hashValue);
    }
}
 