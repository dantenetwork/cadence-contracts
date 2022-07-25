import NonFungibleToken from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;
import SentMessageContract from 0xf8d6e0586b0a20c7;

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


         // create cross chain sent message resource
        let sentMessageVault <-SentMessageContract.createSentMessageVault();
        // save message as resource
        signer.save(<-sentMessageVault, to: /storage/sentMessageVault);
        signer.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault);
        // add acceptor link
        signer.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault);

        // add message submitter
        let msgSubmitter <- SentMessageContract.createMessageSubmitter();
        signer.save(<-msgSubmitter, to: /storage/msgSubmitter);
        signer.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storage/msgSubmitter);
        
    }
}
