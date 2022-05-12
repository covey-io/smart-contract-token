pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

contract CoveyStaking is Initializable {
  IERC777 public stakingToken;
  address owner;


  mapping(address => uint) private _stakedAmounts;

  mapping(address => uint) private _unstakedAmounts;


  address[] public stakers;

  event Staked(address indexed _adr, uint amount);
  
  event Unstaked(address indexed _adr, uint amount);

  event CancelledUnstake(address indexed _adr);

  event Bankrupt(address indexed _adr, uint amountLost);

  event StakeDispensed(address indexed _adr, uint amountDispensed);

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function initialize(address _stakingToken) public initializer {
        owner = msg.sender;
        stakingToken = IERC777(_stakingToken);
    }

  function stake(uint amount) public {
      stakingToken.send(address(this), amount, "Covey Stake");
      _stakedAmounts[msg.sender] = _stakedAmounts[msg.sender] + amount;
      stakers.push(msg.sender);
      emit Staked(msg.sender, amount);
  }

  function unstake(uint amount) public {
      require(_stakedAmounts[msg.sender] != 0, "Has not staked");
      require(_stakedAmounts[msg.sender] - amount >= 0, "Cannot unstake more than total staked amount");
      _unstakedAmounts[msg.sender] = _unstakedAmounts[msg.sender] + amount;
      emit Unstaked(msg.sender, amount);
  }

  function cancelUnstake() public {
      require(_unstakedAmounts[msg.sender] > 0, "No unstake to cancel");
      delete _unstakedAmounts[msg.sender];
      emit CancelledUnstake(msg.sender);
  }

  function getTotalStaked() public view returns(uint) {
      return _stakedAmounts[msg.sender];
  }

  function getTotalUnstaked() public view returns(uint) {
      return _unstakedAmounts[msg.sender];
  }

  function dispenseStakes(address[] memory bankruptAddresses) public onlyOwner {
      for(uint i = 0; i < stakers.length; i++) {
          bool isBankrupt = false;
          for(uint j = 0; j < bankruptAddresses.length; j++) {
              if(bankruptAddresses[j] == stakers[i]) {
                  isBankrupt = true;
              }
          }

          if(isBankrupt) {
              delete _unstakedAmounts[stakers[i]];
              delete _stakedAmounts[stakers[i]];
              delete stakers[i]; 
              emit Bankrupt(stakers[i], _stakedAmounts[msg.sender]);
          } else if( _unstakedAmounts[stakers[i]] > 0) {
              stakingToken.send(stakers[i], _unstakedAmounts[stakers[i]], "Stake dispensal");
              _stakedAmounts[stakers[i]] = _stakedAmounts[stakers[i]] - _unstakedAmounts[stakers[i]];
              _unstakedAmounts[stakers[i]] = 0;

              if(_stakedAmounts[stakers[i]] <= 0) {
                  delete stakers[i];
              }
              emit StakeDispensed(stakers[i], _unstakedAmounts[stakers[i]]);
          }
      }
  }
}