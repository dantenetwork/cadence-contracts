import fcl from '@onflow/fcl';

fcl.config().put('accessNode.api', 'http://127.0.0.1:8080');

(async function () {
  const nftInfo = await fcl.query({
    cadence: `
      import ExampleNFT from 0xf8d6e0586b0a20c7

      // Print the NFTs owned by account 0xf8d6e0586b0a20c7.
      pub fun main(): [UInt64] {
          // Get the public account object for account 0xf8d6e0586b0a20c7
          let nftOwner = getAccount(0xf8d6e0586b0a20c7)
      
          // Find the public Receiver capability for their Collection
          let capability = nftOwner.getCapability<&{ExampleNFT.NFTReceiver}>(ExampleNFT.CollectionPublicPath)
      
          // borrow a reference from the capability
          let receiverRef = capability.borrow()
                  ?? panic("Could not borrow receiver reference")
      
          // Log the NFTs that they own as an array of IDs
          return receiverRef.getIDs();
      }    
      `,
  });

  console.log(nftInfo);
}());

