pragma solidity ^0.8.11;

contract CoveyStakingRewards {
  IERC777 public stakingToken;

  address public owner;

  uint public rewardRate = 100;
  uint public lastUpdateTime;
  uint public rewardPerTokenStored;

  mapping(address => uint) public userRewardPerTokenPaid;
  mapping(address => uint) public rewards;

  uint private _totalSupply;
  mapping(address => uint) private _balances;

  constructor(address _stakingToken) {
    owner = msg.sender;
    stakingToken = IERC777(_stakingToken);
  }

  modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  function rewardPerToken() public view returns (uint) {
    if(_totalSupply == 0) {
      return rewardPerTokenStored;
    }

    return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
  }

   function earned(address account) public view returns (uint) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    /// @notice Change the reward rate for staked tokens
    /// @dev Change the reward rate for staked tokens
    /// @param newRate the rate to now reward for tokens staked
    function changeRewardRate(uint newRate) public onlyOwner {
        rewardRate = newRate;
    }

    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);
    }
}

interface IERC777 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}