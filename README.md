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

## Examples

Flow to Rinkeby

```
# Mint Duanji
flow transactions send ./transactions/createNFT/registerPunster.cdc "I'm punster" "https://raw.githubusercontent.com/wuyahuang/opensea/main/1"

flow transactions send ./transactions/createNFT/publishDuanji.cdc "I found the dog is so funny" "https://raw.githubusercontent.com/wuyahuang/opensea/main/1"

# Tranfer Duanji to locker
flow transactions send ./transactions/CrossChainNFT/sendDuanji2Opensea.cdc 0x70e730a085eb1437b29c36d615c78648ef8be1bc19688b437ecbc1cf89b8b217 0x3aE841B899Ae4652784EA734cc61F524c36325d1 1  

# Sync message from Flow to Rinkeby
node client/nft/flowToEthereum.mjs 1

# Claim Duanji on Rinkeby testnet
node client/crosschain/ethereumClaim.js 1 044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217
```

Rinkeby to Flow
```
# Lock Rinkeby NFT
node client/nft/lockOpenseaDuanji.mjs 1 0x70e730a085eb1437b29c36d615c78648ef8be1bc19688b437ecbc1cf89b8b217

# Transfer NFT from Rinkeby to Flow
node client/nft/ethereumToFlow.mjs 1

# Claim NFT on Flow
node client/crosschain/flowClaim.js 1 044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217

# Burn NFT on Rinkeby
node client/crosschain/burnRinkebyNFT.js 1
```

#### Check NFT on Opensea browser

Wait for some time...You can see new NFT below:

```
https://testnets.opensea.io/assets?search[query]=0x58FEaF2F416feA44B3eA3Cce3AFDC49522e106F7&search[resultModel]=ASSETS
```

Made with ❤️ in Singapore
