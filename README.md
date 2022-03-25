# Smart contracts for cadence
Smart contracts that provide some of the basic functions of the dante cross chain service.

## Version : 0.0.1

This repository contains examples of contracts that are useful when deploying, managing, and/or using an DANTE network. They are provided for reference purposes:

   * [CrossChain](./contracts/CrossChain)
   * [Greeting](./contracts/Greeting)


## Install

* [Install the Flow CLI](https://docs.onflow.org/flow-cli/install/)


## Deploy contracts

```
# generate flow.json for emulator
flow init

# Start local emulator
flow emulator

# Deploy contracts
flow project deploy

# Test greeting contract
flow transactions send tests/testGreeting.cdc

# Update contracts
sh ./updateContract.sh
```

Made with ❤️ in Singapore
