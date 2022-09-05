# Introduction

This document provides a test guide of Dante Protocol Stack along with an Omniverse NFT infrastructure based on Dante. The tests include the following parts:
* [Algorithm test](#algorithm-test) provides an intuitive way to understand how the underlying algoritms work of Dante.
* The working flow of the [Omniverse NFT infrastructure](#omniverse-nft-infrastructure-test) based on Dante checks the complete process of sending an NFT to other chains from Flow and receive the NFT back.
* [SDK Test](#sdk-test) provides examples of how to build Omniverse dApps based on Dante Protocol Stack and tests the basic functions.

# Testing Details
## Algorithm test
### Selection routers
```sh
cd ..

# start the emulator
flow emulator --verbose

# deploy
flow project deploy --update

# register 100 routers with random credibility
flow transactions send ./transactions/test/testRegisterRouter.cdc 101 --gas-limit 10000

# Execute 10,000 times of selectiong and get the statistic result
cd test/offchain

# execute `npm install` if neccessary
npm install
node performance.js
# the result will in the csv file ./data/<newest timestamp>selection.csv
```
Note that we send an empty transaction to refresh the random seed between each epoch.

If everything is OK, we will get the following statistic results:
![flowstatistic](https://user-images.githubusercontent.com/83746881/188304733-bd1535d1-319e-4a19-85fe-342379cb191b.png)

## Message Verification
```sh
cd ..

# start the emulator
flow emulator --verbose

# deploy
flow project deploy --update

# execute the test of message verification
flow scripts execute ./scripts/test/MessageVerificationTest.cdc

# Check the result in emulator log out

# If the result is not what you want, send an empty transaction to refresh the random seed
flow transactions send ./test/transactions/empty.cdc
```

If everything is OK, we will get the following result:
### Success
![1662288359059](https://user-images.githubusercontent.com/83746881/188309763-d4da4e7e-d910-4635-9b41-1707e26817d2.png)
### failed as none of the message copy get enough credibility
![1662288815215](https://user-images.githubusercontent.com/83746881/188309783-d8b525fd-7690-40f6-b024-11819bbb2836.png)

## Routers evaluation
```sh
cd ..

# start the emulator
flow emulator --verbose

# deploy
flow project deploy --update

# execute the test of the router evaluation algorithm
flow scripts execute ./scripts/test/crdTest.cdc

# Check the result in emulator log out
```
If everything is OK, we will get the following result:
![1662289349264](https://user-images.githubusercontent.com/83746881/188310050-401c247e-61dc-4940-ad7b-d9cbe7bd762f.png)  

The curves of the trend are as follows:  
![1662289487999](https://user-images.githubusercontent.com/83746881/188310117-ec5de22b-05a6-4d39-be6e-52c7b4bab3db.png)

## Omniverse NFT infrastructure test

Note to **restart** the emulator when running this test case.

```sh
cd ..

# start the emulator
flow emulator --verbose

# deploy
flow project deploy --update

# Execute the test of the whole process of omniverseNFT
flow scripts execute ./omniverseNFT/scripts/SendNFToutTest.cdc 0xf8d6e0586b0a20c7

# Check the result in emulator log out

```
Note that the test process is executed in the scripts environment and the on-chain status will not change, moreover, I think this is a very nice way to run a Flow test, just as the `cargo test` does in `Rust`. 

Here is the [source code](../omniverseNFT/scripts/SendNFToutTest.cdc) of this test case.
If everything is OK, we will get the following results:
![1662279873281](https://user-images.githubusercontent.com/83746881/188304532-1df3bb23-d0af-43c8-b539-915cfbe44259.png)

## SDK test
### Prepare
Note that if you want to use the SDK in `emulator`, do the following steps for preparing.  
After started the emulator, create an account and transfer some simu-Flow to it for gas as follows:
```sh
flow accounts create --key 81262aa27f1630ccf1293300e8e1d9a6ba542dffa796b860d53873867175e9d31bd7b7581d2f200f9c3dfdbc10ae912ff036946981e3d8996a14f186d20e3e2f

# transfer Flow Token
flow transactions send ./transactions/test/transferFlow.cdc 100.0 0x01cf0e2f2f715450
```
As we have set the address `0x01cf0e2f2f715450` as `emulator-Alice` in `flow.json`, directly execute the scripts above works well and we can use account `emulator-Alice` in emulator now.

