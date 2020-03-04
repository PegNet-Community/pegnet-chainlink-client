pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/vendor/Ownable.sol";

contract PegnetChainLinkConsumer is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;

  uint256 public currentPrice;
  int256 public changeDay;
  bytes32 public lastMarket;

  event RequestEthereumPriceFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  event RequestEthereumChangeFulfilled(
    bytes32 indexed requestId,
    int256 indexed change
  );

  event RequestEthereumLastMarket(
    bytes32 indexed requestId,
    bytes32 indexed market
  );

  constructor() public Ownable() {
    setPublicChainlinkToken();
  }

  function requestPegCurrentPrice(address _oracle, string _jobId, string symbol)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillPegPrice.selector);
    req.add("get", "https://pegnetmarketcap.com/api/asset");
    req.add("extPath", symbol);
    req.add("path", "price");
    req.addInt("times", 10000);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function requestPegPriceChange(address _oracle, string _jobId, string symbol)
    public 
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillPegPriceChange.selector);
    req.add("get", "https://pegnetmarketcap.com/api/asset");
    req.add("extPath", symbol);
    req.add("path", "price_change");
    req.addInt("times", 10000);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);      
  }      
  
  function requestPegVolume(address _oracle, string _jobId, string symbol)
    public 
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId),
    this, this.fulfillPegVolume.selector);
    req.add("get", "https://pegnetmarketcap.com/api/asset");
    req.add("extPath", symbol);
    req.add("path", "volume");
    req.addInt("times", 10000);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);      
  }      
  
  function requestPegSupply(address _oracle, string _jobId, string symbol)
    public 
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId),
    this, this.fulfillPegSupply.selector);
    req.add("get", "https://pegnetmarketcap.com/api/asset");
    req.add("extPath", symbol);
    req.add("path", "supply");
    req.addInt("times", 10000);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);      
  }      
  
  function fulfillPegPrice(bytes32 _requestId, uint256 _price)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestEthereumPriceFulfilled(_requestId, _price);
    currentPrice = _price;
  }

  function fulfillPegPriceChange(bytes32 _requestId, int256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestEthereumChangeFulfilled(_requestId, _change);
    changeDay = _change;
  }

  function fulfillPegVolume(bytes32 _requestId, int256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestEthereumChangeFulfilled(_requestId, _change);
    changeDay = _change;
  }
  
   function fulfillPegSupply(bytes32 _requestId, int256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestEthereumChangeFulfilled(_requestId, _change);
    changeDay = _change;
  } 

  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

}