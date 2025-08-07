// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

contract HelperMaxHoldConfiscate {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AddedHelper(address indexed owner);
    event RemovedHelper(address indexed owner);

    uint256 public immutable maxSupply;
    uint256 public immutable minSupply;
    address public immutable owner;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public helpers;

    constructor() {
        owner = msg.sender;
        maxSupply = 1_000_000_000;
        minSupply = 1_000_000;
    }

    function addHelper(address account) external {
        require(msg.sender == owner, "you cant add helpers");
        helpers[account] = true;
        emit AddedHelper(account);
    }

    function removeHelper(address account) external {
        require(msg.sender == owner, "you cant delete helpers");
        helpers[account] = false;
        emit RemovedHelper(account);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function maxWalletLimit(address account, uint256 value) internal view {
        uint256 maxHoldToken = 1_000_000;
        if (msg.sender == owner || helpers[msg.sender]) {
            return;
        } else if (_balance[account] + value > maxHoldToken) {
            revert("error");
        } else {
            revert("error");
        }    
    }

    function transfer(address to, uint256 value) public returns (bool) {
        uint256 maxSendAmount = 100_000;
        if (_balance[msg.sender] < value) {
            revert("you no have tokens");
        } else if (value > maxSendAmount) {
            revert("limit to send value");
        }
        maxWalletLimit(to,value);
        _balance[msg.sender] -= value;
        _balance[to] += value;
        return true;
    }

    function confiscateToken(address from, address to, uint256 value) external returns (bool) {
        require(msg.sender == owner || helpers[msg.sender], "you no owner/helper");
        require(_balance[from] >= value, "low balance to confiscate");
        _balance[from] -=value;
        _balance[to] += value;
        return true;
    }
}