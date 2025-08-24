// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

abstract contract ERC20 {
    address public owner;
    address public trustAddress;

    constructor(address _trustAddress) payable {
        owner = payable(msg.sender);
        trustAddress = _trustAddress;
    }

    function delegateTest(address newOwner) external payable {
        (bool success, ) = trustAddress.delegatecall(
        abi.encodeWithSelector(Helper.setTest.selector, newOwner));
        require(success == true, "error");
    }

    function receiveCall() external payable {
        (bool success, ) = trustAddress.call{value : msg.value}("");
        require(success, "you cant receive eth");
    }
}

abstract contract Helper {

    address public owner;

    mapping(address => uint256) _balance;

    function setTest(address _owner) external returns (address) {
        owner = _owner;
        return owner;
    }

    function deposit() external payable returns (bool) {
        _balance[msg.sender] += msg.value;
        return true;
    }

    receive() external payable { 
        _balance[msg.sender] += msg.value;
    }
}