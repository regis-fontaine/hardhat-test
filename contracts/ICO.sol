/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WCS_Token is ERC20 {
    constructor() ERC20("EduToken", "WCS") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}

contract WCS_ICO {
    WCS_Token token;
    
    address owner;
    
    mapping(address => uint) public contributorsToTokenAmount;
    
    uint public RATE_ETH = 1000; // price ICO : 1 ether for 1000 WCS tokens
    uint public ethRaised; // in wei
    uint public timeout;
    uint public MIN_CAP = 5000;
    
    bool public isFinalized;
    bool public isSuccessful;
    
    event boughtTokens(address contributor, uint amount);
    event withdrawTokens(address contributor, uint amount);
    
    modifier whenSaleIsActive() {
        require(block.timestamp <= timeout);
        _;
    }
    
    modifier whenSaleIsFinalized() {
        require(isFinalized);
        _;
    }
    
    constructor(WCS_Token _token, uint delay) {
        owner = msg.sender;
        token = _token;
        timeout = block.timestamp + delay;
    }
    
    function buyTokens() public payable whenSaleIsActive {
        uint tokensAmount = msg.value * RATE_ETH;
        ethRaised += msg.value;
        contributorsToTokenAmount[msg.sender] += tokensAmount;
        
        emit boughtTokens(msg.sender, tokensAmount);
    }
    
    function finalize() external {
        require(block.timestamp > timeout);
        isFinalized = true;

        if (ethRaised >= MIN_CAP) {
            isSuccessful = true;
        }
    }
    
    function withdraw() external whenSaleIsFinalized {
        // transfer tokens
        // transfer
        
        require(contributorsToTokenAmount[msg.sender] > 0);
        
        uint tokensAmount = contributorsToTokenAmount[msg.sender];
        contributorsToTokenAmount[msg.sender] = 0;
        
        if (isSuccessful) {
            token.transfer(msg.sender, tokensAmount); // withdraw tokens 
            emit withdrawTokens(msg.sender, tokensAmount);
        } else {
            payable(msg.sender).transfer(tokensAmount / RATE_ETH);  // withdraw eth 
        }
    }
    
    function withdrawEthers() external whenSaleIsFinalized {
        payable(owner).transfer(address(this).balance);  // transfer ethers
    }
    
    function timeleft() external view returns (uint) {
        if (block.timestamp > timeout) {
            return 0;
        }
        
        return timeout - block.timestamp;
    }
    
    function addTimeleft(uint _addTime) external {
        require(owner == msg.sender);
        timeout += _addTime;
    }
    
    receive() external payable {
        buyTokens();
    }
}