// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/* @dev
    the Ownable function allows you to change the owner of the contract
    - which was the default at the time of its creation
    - Ownable is inheritable and has a modifier onlyOwner that you can apply 
    - in different parts of the contract
*/
abstract contract Ownable is Context {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRemoved();

    address private _owner;
    bool internal _statusTrading = false;

    modifier onlyOwner() {
        require(msg.sender == _owner, "error");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function checkOwner() public view returns (bool) {
        return _owner == msg.sender;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function removeOwnership() external onlyOwner {
        _owner = address(0); 
        emit OwnershipRemoved();
    }
}

interface IERC20 {
    
    event Transfer(address indexed owner, address indexed recipient, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event StartedTrading();
    event StoppedTrading();

    function transfer(address recipient, uint256 value) external returns (bool);
    function increaseAllowance(address spender, uint256 value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 value) external returns (bool);
    function decreaseAllowance(address spender, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function startTrading() external;
    function stopTrading() external;
    function TradingAvailability() external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);

}

contract ERC20 is Context, Ownable, IERC20, IERC20Metadata {

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 private immutable _decimals;
    uint256 private immutable _maxSupply;

/* @dev
    - maximum supply is protected, which will protect against malicious minting of tokens 
    - minting is available only after burning a certain number of tokens
*/
    constructor() {
        _name = "Saturn";
        _symbol = "STRN";
        _decimals = 18;
        _totalSupply = 1_000_000_000 * 10 ** _decimals;
        _maxSupply = 1_000_000_000 * 10 ** _decimals;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual returns (uint256) {
        return _decimals;
    }

/* @dev
    standard functions for token trading

Requirements;

    - 'recipient must not be a null address'
    - 'account balance must be greater than the amount sent'
    - 'sender must not be a null address'
    - 'check trading status'

*/
    function transfer(address recipient, uint256 value) public virtual returns (bool) {
        require(recipient != address(0), "recipient is zero address, error");
        require(_balances[_msgSender()] >= value, "you balance low, lets go deposit");
        require(_statusTrading != false, "trading lock");
        _balances[_msgSender()] -= value;
        _balances[recipient] += value;
        emit Transfer(_msgSender(), recipient, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 value) public virtual returns (bool) {
    require(_balances[sender] >= value, "you balance is low");
    require(sender != address(0), "address zero cant send token, error");
    require(recipient != address(0), "address zero cant receive token, error");
    require(_statusTrading != false, "trading lock");
    checkAllowance(sender, recipient, value);
    _balances[sender] -= value;
    _balances[recipient] += value;
    _allowances[sender][_msgSender()] -= value;
    emit Transfer(_msgSender(), recipient, value);
    return true;
    }

/* @dev

    create an Approval event
    
    Requirements:

    - 'sender must not be a null address'
    - 'recipient must not be a null address'
    - 'allowance number must not be zero'
    - 'updates the allowances of participants and allows them to regulate'
*/
    function decreaseAllowance(address spender, uint256 value) public virtual returns (bool) {
        checkAllowance(_msgSender(), spender, value);
        _allowances[_msgSender()][spender] -= value;
        emit Approval(_msgSender(), spender, value);
        return true;
    }

    function checkAllowance(address sender, address recipient, uint256 value) internal pure {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(recipient != address(0), "ERC20: approve to the zero address");
        require(value != 0, "its low value allowance, error");
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        checkAllowance(_msgSender(), spender, value);
        _allowances[_msgSender()][spender] = value;
        emit Approval(_msgSender(), spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 value) public virtual returns (bool) {
        checkAllowance(_msgSender(), spender, value);
        _allowances[_msgSender()][spender] += value;
        emit Approval(_msgSender(), spender, value);
        return true;
    }

/* @dev

    create a Transfer event

    Requirements:

    - 'recipient of tokens during mint must not be a null address'
    - 'require if trading and other transfers are open for accounts'
    - 'require for owner'
    - 'require burn balance check'

*/
    function mint(address account, uint256 value) external {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_statusTrading != false, "trading lock");
        require(_msgSender() == owner(), "you no owner, sorry");
        _totalSupply += value;
        _balances[account] += value;
        emit Transfer(_msgSender(), account, value);
    }

    function burn(address account, uint256 value) external {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_statusTrading != false, "trading lock");
        require(_msgSender() == owner(), "you no owner, sorry");
        require(_balances[account] >= value, "error");
        _totalSupply -= value;
        _balances[account] -= value;
        emit Transfer(_msgSender(), account, value);
    }

/* @dev

    create event StartedTrading
    create event StoppedTrading

    Requirements:

    - 'opens access to trade'
    - 'closes access to trade'
    - 'sends status about trade'
*/
    function startTrading() external {
        require(_msgSender() == owner(), "you no owner");
        _statusTrading = true;
        emit StartedTrading();
    }

    function stopTrading() external {
        require(_msgSender() == owner(), "you no owner");
        _statusTrading = false;
        emit StoppedTrading();
    }

    function TradingAvailability() external view returns (bool) {
        return _statusTrading;
    }
}
