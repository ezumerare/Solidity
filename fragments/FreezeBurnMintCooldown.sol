// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FreezeBurnMintCooldown {
    
    struct datatime {
        uint8 day;
        uint32 minute;
        uint32 second;
        uint256 mintCooldown;
        uint256 burnCooldown;
    }

    uint32 constant day_to_second = 86400;
    uint32 constant day_to_minute = 1440;
    uint256 public constant mintCooldown = 2 * day_to_minute;
    uint256 public constant burnCooldown = 7 * day_to_second;

    address public owner;
    uint256 public totalSupply;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => datatime) private _cooldowns;
    mapping(address => bool) private _isFrozen;

    modifier manager() {
        require(owner == msg.sender, "caller not owner");
        _;
    }   
    
    constructor() {
        owner = msg.sender;
        totalSupply = 100_000;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkBalance(address account) public view returns (uint256) {
        return _balance[account];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(!_isFrozen[from], "account is frozen");
        require(!_isFrozen[to], "account is frozen");
        require(_balance[from] >= value, "error balance");
        require(allowance[from][msg.sender] >= value, "allowance low");
        _balance[from] -= value;
        _balance[to] += value;
        allowance[from][msg.sender] -= value;
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        return transferFrom(msg.sender, to, value);
    }
    function mint(address account, uint256 value) public manager returns (uint256) {
        _balance[account] += value;
        totalSupply += value;
        return totalSupply;
    }

    function mintFrom(address to, uint256 value) public manager returns (uint256) {
        require(block.timestamp >= _cooldowns[msg.sender].mintCooldown, "error");
        _cooldowns[msg.sender].mintCooldown = block.timestamp + mintCooldown;
        _balance[to] += value;
        totalSupply += value;
        return totalSupply;
    }

    function burn(uint256 value) public manager returns (uint256) {
        _balance[msg.sender] -= value;
        totalSupply -= value;
        return totalSupply;
    }

    function burnFrom(address from, uint256 value) public manager returns (uint256) {
        require(_balance[from] >= value, "your balance low, error");
        require(block.timestamp >= _cooldowns[msg.sender].burnCooldown, "you have cooldown");
        _cooldowns[msg.sender].burnCooldown = block.timestamp + burnCooldown;
        _balance[from] -= value;
        totalSupply -= value;
        return totalSupply;
    }

    function isfrozen(address account) public view returns (bool) {
        return _isFrozen[account];
    }

    function freeze(address account) public manager returns (bool) {
        _isFrozen[account] = true;
        return true;
    }
    
    function unfreeze(address account) public manager returns (bool) {
        _isFrozen[account] = false;
        return true;
    }
}