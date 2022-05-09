pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoveyToken is ERC777, Ownable {

  struct TokenLock {
    uint256 amount;
    uint unlockAt;
    string reason;
  }

  struct _Airdrop {
    address recipient;
    uint256 amount;
    uint  lockForSeconds;
    string reason;
  }

  mapping(address => TokenLock[]) _tokenLocks; 

  uint _maxSupply = 1000000000000000000000000000;

  constructor (uint initialSupply, address[] memory defaultOperators) ERC777("Covey", "CVY", defaultOperators) {
    _mint(msg.sender, initialSupply, "", "");
  }


  event Lock(address indexed _adr, uint256 amount, uint indexed unlockTime, string indexed reason);

  event Unlock(address indexed _adr, uint256 amount);

  event Airdrop(address indexed _adr, uint256 amount);

  function _beforeTokenTransfer(
      address operator,
      address from,
      address to,
      uint256 amount
  ) internal virtual override {
    uint256 lockedAmount = 0;

    if(_tokenLocks[from].length > 0) {
      for(uint256 i = 0; i < _tokenLocks[from].length; i++) {
        if(_tokenLocks[from][i].amount != 0 && block.timestamp < _tokenLocks[from][i].unlockAt) {
          lockedAmount += _tokenLocks[from][i].amount;
        }
        
        if(block.timestamp > _tokenLocks[from][i].unlockAt && _tokenLocks[from][i].amount != 0) {
          _unlock(from, i);
        }
      }
    }

    if(lockedAmount > 0) {
      uint256 currentBalance = balanceOf(from);
      uint256 balanceAfter = currentBalance - amount;

      require(balanceAfter > lockedAmount, "Amount being transferred exceeds available unlocked balance");
    }

    super._beforeTokenTransfer(operator,from,to,amount);
  }

  function mint(
    address account,
    uint256 amount,
    bytes memory userData,
    bytes memory operatorData) public onlyOwner {
      require(totalSupply() + amount <= _maxSupply, "Token Minting cannot exceed Max Supply");
      super._mint(account, amount, userData, operatorData);
  }

  function lockedBalanceOf(address tokenHolder) public view returns(uint256) {
    uint256 lockedAmount = 0;
    if(_tokenLocks[tokenHolder].length > 0) {
      for(uint256 i = 0; i < _tokenLocks[tokenHolder].length; i++) {
        if(_tokenLocks[tokenHolder][i].amount != 0 && block.timestamp < _tokenLocks[tokenHolder][i].unlockAt) {
          lockedAmount += _tokenLocks[tokenHolder][i].amount;
        }  
      }
    }

    return lockedAmount;
  }

  function unlockedBalancedOf(address tokenHolder) public view returns(uint256) {
    uint256 lockedAmount = lockedBalanceOf(tokenHolder);

    return balanceOf(tokenHolder) - lockedAmount;
  }

  function getLocks(address tokenHolder) public view returns(TokenLock[] memory) {
    return _tokenLocks[tokenHolder];
  }


  function maxSupply() public view returns(uint) {
    return _maxSupply;
  }


  function airdrop(_Airdrop[] memory airdrops) public  {
    for(uint i = 0; i < airdrops.length; i++) {
      uint256 toSend = airdrops[i].amount * 10**18;
      if(airdrops[i].lockForSeconds != 0) {
        sendLocked(airdrops[i].recipient, airdrops[i].amount, airdrops[i].lockForSeconds, "Locked CVY airdrop");
      } else {
        send(airdrops[i].recipient, toSend, "CVY Airdrop");
        emit Airdrop(airdrops[i].recipient, toSend);
      }
    }
  }

  function sendLocked(address to, uint256 amount, uint timeToLock, string memory reason) public  {
    require(timeToLock > 0, "Time to lock must be more than 0");
    require(to != address(0), "transfer to the zero address");

    uint unlockAt = block.timestamp + timeToLock;
    uint256 toSend = amount * 10**18;
    TokenLock memory tokenLock = TokenLock({
      amount: toSend,
      unlockAt: unlockAt,
      reason: reason
    });
    send(to,toSend, "Locked Tokens");
    _tokenLocks[to].push(tokenLock);
    emit Lock(to, toSend, unlockAt, reason);
  }

  function _unlock(address _adr, uint256 lockIndex) private {
    if(_tokenLocks[_adr][lockIndex].amount != 0) {
      emit Unlock(_adr, _tokenLocks[_adr][lockIndex].amount);
      delete _tokenLocks[_adr][lockIndex];
    }
  }

  function unlock(address _adr, uint256 lockIndex) public onlyOwner {
    _unlock(_adr, lockIndex);
  }
}