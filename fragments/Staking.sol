pragma solidity ^0.8.27;

/*     ATTENTION: this contract is abstract and is NOT INTENDED for full use,
       as it is presented in a simplified version and may be subject to various attacks, 
       use of this contract is strictly at your own risk!
*/

abstract contract tested {
    uint256 private _decimals;
    uint256 private _totalSupply;

    constructor() {
        _decimals = 18;
        _totalSupply = 1_000_000_000 * 10 ** _decimals;
    }

    struct StakerInfo {
        uint256 deposit;
        uint256 lastTimeUpdate;
        uint256 unclaimRewards;
        uint256 withdraw_value;
    }

    uint256 public rewardsPerHour = 400; // 35% APR, 0.004% hour

    mapping(address => StakerInfo) stakers;
    mapping(address => uint256) _balances;
    mapping(address => uint256) _users;

    function deposit(uint256 _value) external {
        uint256 valueReward;
        valueReward = calculateReward();
        if (stakers[msg.sender].deposit == 0) {
            stakers[msg.sender].deposit = _value;
            stakers[msg.sender].lastTimeUpdate = block.timestamp;
        } else {
            stakers[msg.sender].deposit += _value;
            stakers[msg.sender].lastTimeUpdate = block.timestamp;
            stakers[msg.sender].unclaimRewards += valueReward;
        }
        burn(msg.sender, _value);
    }

    function burn(address account, uint256 _value) public {
        require(account != address(0), "its zero address, error");
        require(_balances[account] >= _value, "you balance a few");
        _balances[account] -= _value;
        _totalSupply -= _value;
    }

    function mint(address account, uint256 _value) public {
        require(account != address(0), "its zero address, error");
        _balances[account] += _value;
        _totalSupply += _value;
    }

    function calculateReward() public view returns (uint256) {
        uint256 timerReward;
        uint256 valueReward;
        timerReward = block.timestamp - stakers[msg.sender].lastTimeUpdate;
        valueReward = stakers[msg.sender].deposit * timerReward * rewardsPerHour / 10 ** 18;
        return valueReward;
    }

    function infoRewards() public view returns (uint256 infoStake) {
        infoStake = calculateReward() + stakers[msg.sender].unclaimRewards;
        return (infoStake);
    }

    function claimRewards() external {
        uint256 valueReward;
        uint256 timerReward;
        uint256 timerClaim = 86400; // one day
        require(stakers[msg.sender].deposit > 0, "you havent deposit, error");
        require(block.timestamp - stakers[msg.sender].lastTimeUpdate >= timerClaim, "error");
        timerReward = block.timestamp - stakers[msg.sender].lastTimeUpdate;
        valueReward = stakers[msg.sender].deposit * timerReward * rewardsPerHour / 10 ** 18;
        stakers[msg.sender].lastTimeUpdate = block.timestamp;
        stakers[msg.sender].unclaimRewards = 0;
        mint(msg.sender, valueReward);
    }

    function restakeReward() external {
        uint256 valueReward;
        uint256 timerClaim = 86400; // one day
        require(stakers[msg.sender].deposit > 0, "you not deposited");
        require(block.timestamp - stakers[msg.sender].lastTimeUpdate >= timerClaim, "error");
        valueReward = calculateReward() + stakers[msg.sender].unclaimRewards;
        stakers[msg.sender].lastTimeUpdate = block.timestamp;
        stakers[msg.sender].unclaimRewards = 0;
        mint(msg.sender, valueReward);
    }

    function withdraw() external {
        require(stakers[msg.sender].deposit > 0, "you not deposited");
        stakers[msg.sender].withdraw_value = stakers[msg.sender].deposit + stakers[msg.sender].unclaimRewards;
        stakers[msg.sender].lastTimeUpdate = block.timestamp;
        stakers[msg.sender].unclaimRewards = 0;
        stakers[msg.sender].deposit = 0;
        mint(msg.sender, stakers[msg.sender].withdraw_value);
    }
}
