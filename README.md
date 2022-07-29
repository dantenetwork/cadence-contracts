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

# Ethereum

## Add private key
```
vim client/crosschain/.secret
# Paste your Rinkeby private key
```

## Deploy solidity contracts to rinkeby testnet
```
cd erc721
truffle compile
truffle deploy --network rinkeby --reset --skip-dry-run
```

## Update new NFT contract address
```
examples/Locker.cdc # line 198
config/default.json # line 3
```

# Flow

## Deploy flow contracts
```
# Start local emulator
flow emulator --verbose

# Deploy & Update contracts
flow project deploy --update
```

## Switch emulator to testnet
```
vim config/default.json
# Update network to testnet
# Update flowContractAddress to testnet contract address
```

## Examples

Start Cross Chain Sync Router
```
# Router service responsible for syncing Flow messages to Rinkeby
node client/nft/flowToEthereum.mjs

# Router service responsible for syncing Rinkeby messages to Flow
node client/nft/ethereumToFlow.mjs
```

Flow to Rinkeby

```
# Mint Duanji
flow transactions send ./transactions/createNFT/registerPunster.cdc "I'm punster" "https://raw.githubusercontent.com/wuyahuang/opensea/main/1"

flow transactions send ./transactions/createNFT/publishDuanji.cdc "I found the dog is so funny" "https://raw.githubusercontent.com/wuyahuang/opensea/main/1"

# Query NFT on Flow
flow scripts execute ./scripts/queryDuanjiFrom.cdc 0xf8d6e0586b0a20c7

# Tranfer Duanji to locker
flow transactions send ./transactions/CrossChainNFT/sendDuanji2Opensea.cdc 0x70e730a085eb1437b29c36d615c78648ef8be1bc19688b437ecbc1cf89b8b217 0x71Fa7558e22Ba5265a1e9069dcd2be7c6735BE23 1

# Claim Duanji on Rinkeby testnet
node client/crosschain/ethereumClaim.js 1 044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217
```

Rinkeby to Flow
```
# Lock Rinkeby NFT
node client/nft/lockOpenseaDuanji.mjs 1 0x70e730a085eb1437b29c36d615c78648ef8be1bc19688b437ecbc1cf89b8b217

# Claim NFT on Flow
node client/crosschain/flowClaim.js 1 044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217

# Query NFT on Flow
flow scripts execute ./scripts/queryDuanjiFrom.cdc 0xf8d6e0586b0a20c7

# Burn NFT on Rinkeby
node client/crosschain/burnRinkebyNFT.js 1
```

#### Check NFT on Opensea browser

Wait for some time...You can see new NFT below:
```
https://testnets.opensea.io/assets?search[query]=0xE8B1F67C9e74E6c0338F6B6229DF9D77F76A6Cf6&search[resultModel]=ASSETS
```
