pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC1820Implementer.sol";

contract CoveyStaking is Initializable, IERC777Recipient, IERC777Sender, ERC1820Implementer  {
  IERC777 public stakingToken;

  address owner;


  mapping(address => uint) private _stakedAmounts;

  mapping(address => uint) private _unstakedAmounts;

  address[] public stakers;

  IERC1820Registry public registry;
    
    // keccak256('ERC777TokensRecipient')
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH
        = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;


   // keccak256("ERC777TokensSender")
    bytes32 constant private TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

  event Staked(address indexed _adr, uint amount);
  
  event Unstaked(address indexed _adr, uint amount);

  event CancelledUnstake(address indexed _adr);

  event Bankrupt(address indexed _adr, uint amountLost);

  event StakeDispensed(address indexed _adr, uint amountDispensed);

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function initialize(IERC777 _stakingToken) public initializer {
        owner = msg.sender;
        stakingToken = _stakingToken;

        registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

        registry.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

   function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {

    }

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {}

    function registerHookForAccount(address account) public {
        _registerInterfaceForAddress(
            TOKENS_SENDER_INTERFACE_HASH,
            account
        );
    }

  function stake(uint amount) public {
      require(msg.sender != address(0), "Sender is 0 address");
      require(stakingToken.isOperatorFor(address(this), msg.sender), "Staking contract is not an operator for this address");

      stakingToken.operatorSend(msg.sender, address(this), amount, "Covey Stake", "");
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
              stakingToken.send(stakers[i], _unstakedAmounts[stakers[i]], "Stake dispensal");
              emit StakeDispensed(stakers[i], _unstakedAmounts[stakers[i]]);
              _stakedAmounts[stakers[i]] = _stakedAmounts[stakers[i]] - _unstakedAmounts[stakers[i]];
              _unstakedAmounts[stakers[i]] = 0;

              if(_stakedAmounts[stakers[i]] <= 0) {
                  delete stakers[i];
              }
          }
      }
  }


}