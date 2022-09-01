# Introduction

OmniVerseNFT provides an infrastructure that helps standard NFTs published on Flow be accessed from other chains without losing their special features created on Flow, such as dynamical relationships, executable abilities, and upgradeable attributes.  

OmniVerseNFT is based on Dante protocol stack and of course, it could also be a classical example of how to build with Dante Protocol Stack on Flow.  

OmniVerseNFT is composed of the following components:
* `FlowLocker` provides a safe place for NFTs published on Flow to be temporarily keeped without losing their special features. The NFTs only needs to inherit from the interface [NonFungibleToken.INFT](./contracts/NonFungibleToken.cdc#L78) of the interface contract [NonFungibleToken](./contracts/NonFungibleToken.cdc).   
* `StarRealm`: 
