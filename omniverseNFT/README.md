# Introduction

OmniVerseNFT provides an infrastructure that helps standard NFTs published on Flow be accessed from other chains without losing their special features created on Flow, such as dynamical relationships, executable abilities, and upgradeable attributes.  

OmniVerseNFT is based on Dante protocol stack and of course, it could also be a classical example of how to build with Dante Protocol Stack on Flow.  

OmniVerseNFT is composed of the following components:
* [StarLocker](./contracts/StarLocker.cdc) provides a safe place for NFTs published on Flow to be temporarily keeped without losing their special features. The NFTs only needs to inherit from the interface [NonFungibleToken.INFT](./contracts/NonFungibleToken.cdc#L78) of the interface contract [NonFungibleToken](./contracts/NonFungibleToken.cdc). NFTs are stored in `StarLocker` safely in the following steps:
    * When an NFT is docked into the `StarLocker`, there will be a hash value along with it.  
    * And next this NFT and the related hash value will be delivered to other chains by Dante Protocol and there is a same `StarLocker` deployed on the target chain.  
    * No one could claim away the NFT on the target chain unless they know the answer of the hash value.
    * The process of how the NFT coming back Flow is very similar. 
* [StarRealm](./contracts/StarRealm.cdc) provides an standard interface to trading all kinds of NFTs between users. Unlike [NFTForwarding.cdc](./contracts/utility/NFTForwarding.cdc), `StarRealm` supports `@AnyResource{NonFungibleToken.INFT}`, which we think is more generic than type `NonFungibleToken.NFT`.  
