# Smart contracts for cadence
Smart contracts that provide some of the basic functions of the dante cross chain service.

## Version : 1.0

This repository contains examples of contracts that are useful when deploying, managing, and/or using an DANTE network. They are provided for reference purposes:

   * [SentMessageContract](./contracts/SentMessageContract)
   * [ReceivedMessageContract](./contracts/ReceivedMessageContract)
   * [CrossChain](./contracts/CrossChain)
   * [Greeting](./examples/Greeting)


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

## Test greeting contract
```
node client/testGreeting.mjs
```

## Query onchain data by Node.js
```
node client/query.js
```

Made with ❤️ in Singapore
