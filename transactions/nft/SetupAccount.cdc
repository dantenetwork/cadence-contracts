import NonFungibleToken from 0x166d0e1b0499cde8;
import ExampleNFT from 0x166d0e1b0499cde8;

// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {
        // Return early if the account already has a collection
        if signer.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- ExampleNFT.createEmptyCollection()

        // save it to the account
        signer.save(<-collection, to: ExampleNFT.CollectionStoragePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic}>(
            ExampleNFT.CollectionPublicPath,
            target: ExampleNFT.CollectionStoragePath
        )
    }
}
