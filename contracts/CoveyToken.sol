pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoveyToken is ERC777, Ownable {

  struct TokenLock {
    uint256 amount;
    uint unlockAt;
  }

  mapping(address => TokenLock) _tokenLocks; 

  constructor (uint initialSupply, address[] memory defaultOperators) ERC777("Covey", "CVY", defaultOperators) {
    _mint(msg.sender, initialSupply, "", "");
  }


  event LockedTokensSent(address to, uint256 amount, uint unlockTime);

  event TokensReleased(address to, uint256 amount);

  function isActive() view internal returns (bool) {
    return (
        balanceOf(owner()) > 0
    );
  }

  function _beforeTokenTransfer(
      address operator,
      address from,
      address to,
      uint256 amount
  ) internal virtual override {
    if(_tokenLocks[from].amount != 0 && block.timestamp < _tokenLocks[from].unlockAt) {
      uint256 currentBalance = balanceOf(from);
      uint256 balanceAfter = currentBalance - amount;

      require(balanceAfter > _tokenLocks[from].amount, "Amount being transferred exceeds available unlocked balance");
    }
    
    if(block.timestamp > _tokenLocks[from].unlockAt && _tokenLocks[from].amount != 0) {
      delete _tokenLocks[from];
      emit TokensReleased(from, amount);
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
    _tokenLocks[to].amount = _tokenLocks[to].amount + amount;
    _tokenLocks[to].unlockAt = unlockAt;
    uint256 toSend = amount * 10**18;
    send(to,toSend, "Locked Tokens");
    emit LockedTokensSent(to, toSend, unlockAt);
  }

  function removeTokenLock(address to, uint256 amount) public onlyOwner {
    if(_tokenLocks[to].amount != 0) {
      delete _tokenLocks[to];
      emit TokensReleased(to, amount);
    }
  }
}