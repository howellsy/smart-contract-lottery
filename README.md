# Smart Contract Lottery

A provably fair and verifiably random lottery written in Solidity leveraging:

-   Chainlink VRF for randomness
-   Chainlink Automation for time based trigger

You can see this smart contract deployed on Sepolia [here](https://sepolia.etherscan.io/address/0xf714e378541ab176a8d7681aa33e981c9e85f41d).

## ⚒️ Built with Foundry

This project is built with [Foundry](https://github.com/foundry-rs/foundry) a portable and modular toolkit for Ethereum application development, which is required to build and deploy the project.

## 🏗️ Getting started

Create a `.env` file with the following entries:

```
SEPOLIA_RPC_URL=<sepolia_rpc_url>
PRIVATE_KEY=<private_key>
ETHERSCAN_API_KEY=<etherscan_api_key>
```

Install project dependencies

```
make install
```

Deploy the smart contract on Anvil

```
make anvil
make deploy
```

Deploy the smart contract on Sepolia

```
make deploy ARGS="--network sepolia"
```

## 🧪 Running tests

To run against a local Anvil Ethereum node:

```
forge test
```

To run against a forked environment (e.g. a forked Sepolia testnet):

```
forge test --fork-url <sepolia_rpc_url>
```
