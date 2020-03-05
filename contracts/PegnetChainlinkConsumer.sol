pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/vendor/Ownable.sol";

contract PegnetChainLinkConsumer is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;

  uint256 public currentPrice;
  uint256 public lastUpdate;
  uint256 public volume;
  uint256 public supply;

  event RequestCurrentPriceFulfilled(
    bytes32 indexed requestId,
    uint256 indexed currentPrice
  );

  event RequestLastUpdateFulfilled(
    bytes32 indexed requestId,
    uint256 indexed lastUpdate
  );

  event RequestVolumeFulfilled(
    bytes32 indexed requestId,
    uint256 indexed volume
  );

  event RequestSupplyFulfilled(
    bytes32 indexed requestId,
    uint256 indexed supply
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

  function requestPegLastUpdate(address _oracle, string _jobId, string symbol)
    public 
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillPegLastUpdate.selector);
    req.add("get", "https://pegnetmarketcap.com/api/asset");
    req.add("extPath", symbol);
    req.add("path", "updated_at");
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
    emit RequestCurrentPriceFulfilled(_requestId, _price);
    currentPrice = _price;
  }

  function fulfillPegLastUpdate(bytes32 _requestId, uint256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestLastUpdateFulfilled(_requestId, _change);
    lastUpdate = _change;
  }

  function fulfillPegVolume(bytes32 _requestId, uint256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestVolumeFulfilled(_requestId, _change);
    volume = _change;
  }
  
   function fulfillPegSupply(bytes32 _requestId, uint256 _change)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestSupplyFulfilled(_requestId, _change);
    supply = _change;
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