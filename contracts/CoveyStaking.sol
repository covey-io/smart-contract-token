pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract CoveyStaking is Initializable {
  IERC20 public stakingToken;

  struct StakeInfo {
      address staker;
      uint stakedAmount;
  }

  address owner;


  mapping(address => uint) private _stakedAmounts;

  mapping(address => uint) private _unstakedAmounts;

  address[] public stakers;

  event Staked(address indexed _adr, uint amount);
  
  event Unstaked(address indexed _adr, uint amount);

  event TotalStaked(address indexed _adr, uint amount);
  
  event TotalUnstaked(address indexed _adr, uint amount);

  event CancelledUnstake(address indexed _adr);

  event Bankrupt(address indexed _adr, uint amountLost);

  event StakeDispensed(address indexed _adr, uint amountDispensed);

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function initialize(IERC20 _stakingToken) public initializer {
        owner = msg.sender;
        stakingToken = _stakingToken;
    }

   

  function stake(uint amount) public {
      require(msg.sender != address(0), "Sender is 0 address");
      require(amount <= stakingToken.balanceOf(msg.sender), "Amount exceeds available CVY balance");

      stakingToken.transferFrom(msg.sender, address(this), amount);
      _stakedAmounts[msg.sender] +=  amount;
      stakers.push(msg.sender);
      emit Staked(msg.sender, amount);
      emit TotalStaked(msg.sender, _stakedAmounts[msg.sender]);
  }

  function unstake(uint amount) public {
      require(_stakedAmounts[msg.sender] != 0, "Has not staked");
      require(_stakedAmounts[msg.sender] - (_unstakedAmounts[msg.sender] + amount) >= 0, "Cannot unstake more than total staked amount");
      _unstakedAmounts[msg.sender] += amount;
      emit Unstaked(msg.sender, amount);
      emit TotalUnstaked(msg.sender, _unstakedAmounts[msg.sender]);
  }

  function cancelUnstake() public {
      require(_unstakedAmounts[msg.sender] > 0, "No unstake to cancel");
      delete _unstakedAmounts[msg.sender];
      emit CancelledUnstake(msg.sender);
  }

  function getTotalStaked(address _adr) public view returns(uint) {
      return _stakedAmounts[_adr];
  }

  function getTotalUnstaked(address _adr) public view returns(uint) {
      return _unstakedAmounts[_adr];
  }

  function dispenseStakes(address[] calldata bankruptAddresses) public onlyOwner {
      for(uint i = 0; i < stakers.length; i++) {
          bool isBankrupt = false;
          for(uint j = 0; j < bankruptAddresses.length; j++) {
                if(bankruptAddresses[j] == stakers[i]) {
                    isBankrupt = true;
                }
            }

          if(isBankrupt == true) {
              emit Bankrupt(stakers[i], _stakedAmounts[stakers[i]]);
              delete _unstakedAmounts[stakers[i]];
              delete _stakedAmounts[stakers[i]];
              delete stakers[i]; 
          } else if( _unstakedAmounts[stakers[i]] > 0 && isBankrupt == false) {
              stakingToken.transfer(stakers[i], _unstakedAmounts[stakers[i]]);
              emit StakeDispensed(stakers[i], _unstakedAmounts[stakers[i]]);
              _stakedAmounts[stakers[i]] = _stakedAmounts[stakers[i]] - _unstakedAmounts[stakers[i]];
              _unstakedAmounts[stakers[i]] = 0;

              if(_stakedAmounts[stakers[i]] <= 0) {
                  delete stakers[i];
              }
          }
      }
  }

  function getNetStaked(address staker) public view returns (uint) {
      require(staker != address(0), "Sender is 0 address");
      
      return _stakedAmounts[staker] - _unstakedAmounts[staker];
  }

  function getAllNetStaked() public view returns (StakeInfo[] memory) {
      StakeInfo[] memory stakeInformation;

      for(uint i = 0; i < stakers.length; i++) {
          stakeInformation[i] = StakeInfo({
              staker: stakers[i],
              stakedAmount: getNetStaked(stakers[i])
          });
      }

      return stakeInformation;
  }
}