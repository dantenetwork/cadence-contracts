import MetadataViews from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;
import NFTCrossChain from 0xf8d6e0586b0a20c7;

transaction(address: Address, id: UInt64) {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    let ethereumContractName = "ethereumContractName";
    let ethereumActionName = "ethereumActionName";
    
    let account = getAccount(address);

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection");

    let nft = collection.borrowExampleNFT(id: id)!

    // Get the basic display information for this NFT
    let view = nft.resolveView(Type<MetadataViews.Display>())!

    let display = view as! MetadataViews.Display;
    
    let owner: Address = nft.owner!.address!;
    let nftType = nft.getType();

    let nftData = display.name.concat(display.description).concat(display.thumbnail.uri()).concat(owner.toString()).concat(nftType.identifier);

    NFTCrossChain.sendCrossChainMessage(toChain:"Ethereum", contractName:ethereumContractName , actionName:ethereumActionName, data: nftData);
  }
}