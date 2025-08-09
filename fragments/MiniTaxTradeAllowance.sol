// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

abstract contract MiniTaxTradeAllowance {
    
    event buyTaxChanged(uint256 buyTax);
    event sellTaxChanged(uint256 sellTax);
    event OpenTrading();
    event CloseTrading();
    event Approval(address indexed owner, address indexed spender, uint value);

    uint256 public transferTax;
    uint256 public buyTax;
    uint256 public sellTax;
  
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public taxWallet;
    address public owner;
    bool private tradeAvailable = false;

    constructor() {
        owner = msg.sender;
    }

    function setBuyTax(uint256 value) external {
        require(msg.sender == owner, "you can't edit tax");
        require(value <= 100, "forbidden set tax higher %100");
        buyTax = value;
        emit buyTaxChanged(value);
    }
    
    function setSellTax(uint256 value) external {
        require(msg.sender == owner, "you can't edit tax");
        require(value <= 100, "forbidden set tax higher %100");
        sellTax = value;
        emit sellTaxChanged(value);
    }
    
    function approve(address spender, uint256 value) public {
        require(spender != address(0), "address is zero");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function increaseAllowance(address spender, uint256 value) public virtual returns (bool) {
        require(spender != address(0), "address spender is zero, error");
        allowance[msg.sender][spender] += value;
        return true;

    }
    function transferFrom(address sender, address recipient, uint256 value) public virtual returns (bool) {
        require(sender != address(0), "address sender is zero, error");
        require(recipient != address(0), "address recipient is zero, error");
        require(balanceOf[sender] >= value, "error");
        require(tradeAvailable, "trading off");
        uint256 taxValue = value * transferTax / 100;
        uint256 finalValue = value - taxValue;
        balanceOf[sender] -= value;
        balanceOf[taxWallet] += taxValue;
        balanceOf[recipient] += finalValue;
        allowance[sender][msg.sender] -= value;
        return true;
    }

    function decreaseAllowance(address spender, uint256 value) public virtual returns (bool) {
        require(spender != address(0), "address spender is zero, stop");
        allowance[msg.sender][spender] -= value;
        return true;
    }

    function transfer(address recipient, uint256 value) external {
        require(recipient != address(0), "address recipient is zero, error");
        require(balanceOf[msg.sender] >= value, "error");
        uint256 taxValue = value * transferTax / 100;
        uint256 finalValue = value - taxValue;
        balanceOf[taxWallet] += taxValue; 
        balanceOf[msg.sender] -= value;
        balanceOf[recipient] += finalValue;
    }

    function tradeEnable() external {
        require(msg.sender == owner, "error edit trade");
        tradeAvailable = true;
        emit OpenTrading();
    }

    function tradeDisable() external {
        require(msg.sender == owner, "error edit trade");
        tradeAvailable = false;
        emit CloseTrading();
    }
}
