## This repository contains two parts
1. ### Pegnet Chainlink Contracts 
Contracts contains an implementation of Chainlink oracle contract which can be used by any Ethereum dApp to request data for any pegnet.
2. ### Chainlink Peg data prices 
Server repository scrapes data from Chainlink feed from https://feeds.chain.link/ and returns prices for all symbols with USD pairs


Implementation of a [Chainlink requesting contract](https://docs.chain.link/docs/create-a-chainlinked-project) to fetch peg attributes from 
[Pegnet Explorer API](https://pegnetmarketcap.com/).

This chainlink smart contract can be used to query and create Chainlink oracles for a given peg price, volume, supply or price change by peg symbol.

## How to run

### To run the scraping server
The server is an Express/NodeJS app.
```
cd server
sudo npm install
npm start
```
This will start the scraping server at port 3000. The latest chainlink feed data can then be requested by sending a GET request to http://localhost:3000
This can further be deployed on a instance to provide a static IP which all pegnet Oracle miners can query from.
Sample response would look like

```
{"data":[{"symbol":"ETH","price":"238.245"},{"symbol":"BTC","price":"9118.641"},
{"symbol":"AUD","price":"0.663"},{"symbol":"EUR","price":"1.131497"},
{"symbol":"CHF","price":"1.068"},{"symbol":"GBP","price":"1.299"},
{"symbol":"JPY","price":"0.00950606"},{"symbol":"XAG","price":"17.308"},
{"symbol":"XAU","price":"1687.745"},{"symbol":"LINK","price":"4.664"}]}
```

### To deploy the contracts
1. Go to the contract file /contracts/PegnetChainlinkConsumer.sol and uncomment the line 10 of the file to set the link price for each request.

For mainnet request prices check the price of your chosen of your oracle provider node here https://docs.chain.link/docs/decentralized-oracles-ethereum-mainnet#config
For Testnet deployments request prices are simplified to 1 Link for 1 request.

2. Compile and deploy the contracts to your network of choice.

3. Fund the contract with Chainlink token. 
For Ropsten you get request chainlink token from the faucet at https://ropsten.chain.link/



Method definitions -
The contract allows any smart contract to request the following attibutes of each pegged token.

1. To request current price of a pegged token call the `requestPegCurrentPrice` method
2. To request last updated timestamp of a pegged token call the `requestPegLastUpdate` method
3. To request last volume of the pegged token call the `requestPegVolume` method.
4. To request last reported of the pegged token call the `requestPegSupply` method.


Each method takes in three arguments.
The `oracle_address`, `job_id` and `symbol` of the pegged token.


For instance to request the current price of the pETH pegged token on Ropsten network, a consumer smart contract will send a request to 
`requestPegCurrentPrice("0xc99B3D447826532722E41bc36e644ba3479E4365", "3cff0a3524694ff8834bda9cf9c779a1", "pETH")`

The complete list of chainlink oracle addresses and job ids on the testnet can be obtained [here](https://docs.chain.link/docs/testnet-oracles) and for the mainnet can be obtained [here](https://docs.chain.link/docs/decentralized-oracles-ethereum-mainnet#config).