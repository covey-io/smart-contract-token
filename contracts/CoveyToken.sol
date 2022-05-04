pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoveyToken is ERC777, Ownable {

  struct TokenLock {
    uint256 amount;
    uint unlockAt;
  }

  mapping(address => TokenLock[]) _tokenLocks; 

  constructor (uint initialSupply, address[] memory defaultOperators) ERC777("Covey", "CVY", defaultOperators) {
    _mint(msg.sender, initialSupply, "", "");
  }


  event LockedTokensSent(address _adr, uint256 amount, uint unlockTime);

  event TokensReleased(address _adr, uint256 amount);

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
          _removeTokenLock(from, i);
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


  function airdrop  (address[] memory recipients, uint256[] memory amounts, uint256[] memory lockForSeconds) public onlyOwner {
    for(uint i = 0; i < recipients.length; i++) {
      uint256 toSend = amounts[i] * 10**18;
      if(lockForSeconds[i] != 0) {
        sendLocked(recipients[i], amounts[i], lockForSeconds[i]);
      } else {
        send(recipients[i], toSend, "Covey Airdrop");
      }
    }
  }

  function sendLocked(address to, uint256 amount, uint timeToLock) public onlyOwner {
    require(timeToLock > 0, "Time to lock must be more than 0");
    uint unlockAt = block.timestamp + timeToLock;
    uint256 toSend = amount * 10**18;
    TokenLock memory tokenLock = TokenLock({
      amount: toSend,
      unlockAt: unlockAt
    });
    _tokenLocks[to].push(tokenLock);
    send(to,toSend, "Locked Tokens");
    emit LockedTokensSent(to, toSend, unlockAt);
  }

  function _removeTokenLock(address _adr, uint256 lockIndex) private {
    if(_tokenLocks[_adr][lockIndex].amount != 0) {
      emit TokensReleased(_adr, _tokenLocks[_adr][lockIndex].amount);
      delete _tokenLocks[_adr][lockIndex];
    }
  }

  function removeTokenLock(address _adr, uint256 lockIndex) public onlyOwner {
    _removeTokenLock(_adr, lockIndex);
  }
}