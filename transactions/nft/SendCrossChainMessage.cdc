import MetadataViews from 0xf8d6e0586b0a20c7;
import ExampleNFT from 0xf8d6e0586b0a20c7;
import NFTCrossChain from 0xf8d6e0586b0a20c7;

transaction(address: Address, id: UInt64) {

  let signer: AuthAccount;

  prepare(acct: AuthAccount) {
    self.signer = acct;
  }

  execute {
    let ethereumContractName = "0x66e4877C17b2044033c436Ea064770fAB565372E";
    let ethereumActionName = "mintTo";
    
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

    let nftData = display.name.concat("#").concat(display.description).concat("#").concat(display.thumbnail.uri());

    NFTCrossChain.sendCrossChainMessage(toChain:"Ethereum", contractName:ethereumContractName , actionName:ethereumActionName, data: nftData);
  }
}