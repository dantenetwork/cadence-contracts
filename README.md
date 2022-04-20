# Smart contracts for cadence
Smart contracts that provide some of the basic functions of the dante cross chain service.

## Version : 0.0.1

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

# Deploy contracts to testnet
flow project deploy --network testnet

# Update contracts
sh ./updateContract.sh
```

## Examples

#### Mint NFT
```
// Setup account & mint NFT 
// Success when `Tx Sent: {...` is shown
node client/nft/MintNFT.mjs

// Query NFT meda data by Node.js
node client/nft/queryNFT.mjs

// Query sent cross chain message By Node.js
node client/nft/querySentMessage.mjs
```

#### Check NFT on Opensea browser

Wait for some time...You can see new NFT below:

```
https://testnets.opensea.io/assets?search[query]=0xe524839f9CD9Eb9b3Cb166511Ba5179179ce65e8&search[resultModel]=ASSETS
```

Made with ❤️ in Singapore
