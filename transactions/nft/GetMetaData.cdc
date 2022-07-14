import MetadataViews from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;

pub struct NFT {
    pub let tokenURL: String
    pub let owner: Address
    pub let type: String

    init(
        tokenURL: String,
        owner: Address,
        nftType: String,
    ) {
        self.tokenURL = tokenURL
        self.owner = owner
        self.type = nftType
    }
}

pub fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    // Get the basic display information for this NFT
    let view = nft.resolveView(Type<MetadataViews.Display>())!

    let display = view as! MetadataViews.Display
    
    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    return NFT(
        tokenURL: display.tokenURL,
        owner: owner,
        nftType: nftType.identifier,
    );
}
