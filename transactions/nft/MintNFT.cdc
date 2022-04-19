import NonFungibleToken from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;
import NFTCrossChain from 0xf8d6e0586b0a20c7;

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(
    recipient: Address,
    name: String,
    description: String,
    thumbnail: String
) {
    execute {
      NFTCrossChain.mintNFT(recipient:recipient,name:name,description:description,thumbnail:thumbnail);
    }
}