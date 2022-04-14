# Smart contracts for cadence
Smart contracts that provide some of the basic functions of the dante cross chain service.

## Version : 1.0

This repository contains examples of contracts that are useful when deploying, managing, and/or using an DANTE network. They are provided for reference purposes:

   * [SentMessageContract](./contracts/SentMessageContract.cdc)
   * [ReceivedMessageContract](./contracts/ReceivedMessageContract.cdc)
   * [CrossChain](./contracts/CrossChain.cdc)
   * [ExampleNFT](./examples/ExampleNFT.cdc)


## Install
* [Install the Flow CLI](https://docs.onflow.org/flow-cli/install/)


## Deploy contracts
```
# Generate flow.json for emulator
flow init

# Start local emulator
flow emulator

# Deploy contracts
flow project deploy

# Update contracts
sh ./updateContract.sh
```

## Examples

#### NFT
```
// Setup account & mint NFT 
node client/nft/mintNFT.mjs

// Query onchain data by Node.js
node client/nft/queryNFT.js
```

```
// Send cross chain message
node client/nft/testSendMessage.mjs

// Query cross chain message
node client/nft/querySendMessage.mjs
```

## CrossChain
```
// Start sync node
node client/crosschain/crossChainSync.js
```

Made with ❤️ in Singapore
