pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

contract CoveyStaking is Initializable {
  IERC777 public stakingToken;
  address owner;

  mapping(address => uint) private _stakes;

  mapping(address => uint) private _unstakes;

  event Stake(address indexed _adr, uint amount);
  
  event Unstake(address indexed _adr, uint amount);

  event CancelledUnstake(address indexed _adr);

  function initialize(address _stakingToken) public initializer {
        owner = msg.sender;
        stakingToken = IERC777(_stakingToken);
    }

  function stake(uint amount) public {
      stakingToken.send(address(this), amount, "Covey Stake");
      _stakes[msg.sender] = _stakes[msg.sender] + amount;
      emit Stake(msg.sender, amount);
  }

  function unstake(uint amount) public {
      require(_stakes[msg.sender] != 0, "Has not staked");
      require(_stakes[msg.sender] - amount >= 0, "Cannot unstake more than total staked amount");
      _unstakes[msg.sender] = _unstakes[msg.sender] + amount;
      emit Unstake(msg.sender, amount);
  }

  function cancelUnstake() public {
      require(_unstakes[msg.sender] > 0, "No unstake to cancel");
      delete _unstakes[msg.sender];
      emit CancelledUnstake(msg.sender);
  }
  
}