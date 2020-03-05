# Pegnet Chainlink contract

Implementation of a [Chainlink requesting contract](https://docs.chain.link/docs/create-a-chainlinked-project) to fetch peg attributes from 
[Pegnet Explorer API](https://pegnetmarketcap.com/api/asset/all).


This chainlink smart contract can be used to query and create Chainlink oracles for a given peg price, volume, supply or price change by peg symbol.



## How to run
1. Compile and deploy the contracts to your network of choice.

2. Fund the contract with Chainlink token. 
For Ropsten you get request chainlink token at https://ropsten.chain.link/


3. To request current price call the `requestPegCurrentPrice` method
4. To request last updated timestamp call the `requestPegLastUpdate` method
5. To request last volume of the pegged token call the `requestPegVolume` method.
6. To request last reported of the pegged token call the `requestPegSupply` method.


Each method takes in three arguments.
The oracle address, job id and symbol of the pegged token.

Tthe complete list of chainlink oracle addresses and job ids on the testnet can be obtained [here](https://docs.chain.link/docs/testnet-oracles) and for the mainnet can be obtained [here](https://docs.chain.link/docs/decentralized-oracles-ethereum-mainnet#config).