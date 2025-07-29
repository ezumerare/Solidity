pragma solidity ^0.8.0;

interface cont {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256);
    function mint(uint amount) external returns (bool);
    function burn(uint amount) external returns (bool);
    function renounceOwnership() external;
    function transfer(address recipient, uint value) external returns (bool);
    function transferFrom(address sender, address recipient, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
}
contract two is cont {

    address public _owner;
    string public _symbol;
    string public _name;
    uint8 public _decimals = 18;
    uint256 public _totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
   
   modifier onlyOwner() {
     require(msg.sender == _owner, "not have law this token");
     _;
   }

    constructor() {
     _owner = msg.sender;
     _symbol = "TEST";
     _name = "tested";
     _totalSupply = 1_000_000_000 * 10 ** 18;
    }   
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
  
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function mint(uint amount) public override(cont) onlyOwner returns (bool) {
        _totalSupply += amount;
        balanceOf[msg.sender] += amount;
        return true;
    }

    function burn(uint amount) public override(cont) onlyOwner returns (bool) {
        _totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        return true;
    }

    function renounceOwnership() public override(cont) onlyOwner {
        _owner = address(0);
    }

    function transfer(address recipient, uint amount) public override(cont) returns (bool) {
        require(balanceOf[msg.sender] >= amount, "not have tokens");
        address sender = msg.sender;
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;

    }
    
    function transferFrom(address sender, address recipient, uint amount) public override(cont) returns (bool) {
        require(balanceOf[sender] >= amount, "not have tokens");
        require(allowance[sender][msg.sender] >= amount, "not have allowance");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function approve(address spender, uint amount) public override(cont) returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}  
