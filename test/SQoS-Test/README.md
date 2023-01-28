# SQoS Test Guide

this test guide is specific to the functions of the `SQoS`. As the workflow of the `SQoS` is a bit complex, we need some special tools for testing.  
As a result, we have made out a powerful simulator to help us complete the test.  

## Install Dante Protocol for Flow

- Clone the repo

    ```sh
    git clone git@github.com:dantenetwork/cadence-contracts.git -b SQoS
    ```

- Install the protocol

    ```sh
    cd cadence-contracts
    # install
    ./emulator_init.sh
    ```

## Install Dante SDK for Flow

- Clone the repo

    ```sh
    cd ..
    # clone
    git clone git@github.com:dantenetwork/flow-sdk.git -b SQoS
    ```

    or `Use this templete` to create a new Dapp based on Dante Protocol.

- Install the test environment

    ```sh
    cd flow-sdk/exampleApp/computation

    # install
    ./init.sh
    ```

## Install the simulator

- Clone the repo from GitHub

    ```sh
    cd ..
    # clone
    git clone git@github.com:dantenetwork/flow-off-chain.git -b SQoS
    ```

- Go to the repo

    ```sh
    cd flow-off-chain
    # install
    npm install
    ```

## Testing Index

- [Error Rollback](./error-rollback.md)
- [hidden reveal](./hidden-reveal.md)
- [challenge](./challenge.md)

### Simplest Situation

***Note that suppose we have put the repos `/cadence-contracts`, `/flow-sdk`, and `/flow-off-chain` in the same directory.***  
