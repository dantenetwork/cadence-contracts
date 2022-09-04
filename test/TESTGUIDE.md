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
If everything is OK, we will get the following statistic results:


## Message Verification


## Routers evaluation


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


## SDK test
