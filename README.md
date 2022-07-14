# Protocol stack for cadence
Smart contracts that provide some of the basic functions of the dante protocol stack to make dApps on Flow be Omnichain.

## Version : 0.0.1

This repository contains examples of contracts that are useful when deploying, managing, and/or using an DANTE network. They are provided for reference purposes:

   * [SentMessageContract](./contracts/SentMessageContract.cdc)
   * [ReceivedMessageContract](./contracts/ReceivedMessageContract.cdc)
   * [CrossChain](./contracts/CrossChain.cdc)
   * [ExampleNFT](./examples/ExampleNFT.cdc)


## Install
* [Install the Flow CLI](https://docs.onflow.org/flow-cli/install/)

## Important note
The private keys included in flow.json & default.json are used for test net debugging only. 

## Deploy solidity contracts to rinkeby testnet
```
cd erc721
truffle compile
truffle deploy --network rinkeby --reset --skip-dry-run
```

## Update new NFT contract address
```
vim transactions/nft/MintNFT.cdc # line 41
```

## Mint NFT on rinkeby testnet
```
cd erc721
node scripts/mint.js
```

## Deploy flow contracts
```
# Generate flow.json for emulator(Local Test Only)
flow init

# Start local emulator
flow emulator

# Deploy contracts
flow project deploy

# Update contracts
flow project deploy --update

# Deploy contracts to testnet
flow project deploy --network testnet

# Create locker account
flow accounts create --key bb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025 --signer emulator-account

# Update locker account address to locker.address of config/default.json
# Update locker account address to locker of transactions/nft/CrossChainTransferNFT.cdc

# Create NFT collection for locker account
node client/nft/setupLockerAccount.mjs
```

## Examples

#### Mint NFT to recipient
```
# Setup account & mint NFT 
# Success when `Tx Sent: {...` is shown
node client/nft/mintNFT.mjs

# Query NFT meda data by Node.js
node client/nft/queryNFT.mjs

# Tranfer NFT to locker and send cross chain message
node client/nft/crossChainTransferNFT.mjs 

# Query sent cross chain message By Node.js
node client/nft/querySentMessage.mjs
```

#### Check NFT on Opensea browser

Wait for some time...You can see new NFT below:

```
https://testnets.opensea.io/assets?search[query]=0x263037FdFa433828fCBF97B87200A0E0b8d68C5f&search[resultModel]=ASSETS
```

Made with ❤️ in Singapore
