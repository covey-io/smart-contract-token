pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoveyToken is ERC777, Ownable {

  mapping(address => uint) _tokenLocks; 

  constructor (uint initialSupply, address[] memory defaultOperators) ERC777("Covey", "CVY", defaultOperators) {
    _mint(msg.sender, initialSupply, "", "");
  }

  modifier _onlyOwnerOrOperators {
    require(msg.sender == address(this) || msg.sender == owner() || isOperatorFor(msg.sender, address(this)), "Only owner or operator can call this function");
    _;
  }

  modifier whenDropIsActive() {
    assert(isActive());

    _;
  }

  event LockedTokensSent(address to, uint256 amount, uint unlockTime);

  event TokensReleased(address to, uint256 amount);

  function isActive() view internal returns (bool) {
    return (
        balanceOf(owner()) > 0
    );
  }

  function transfer(address recipient, uint256 amount) public override returns(bool) {
    if(_tokenLocks[msg.sender] != 0 && block.timestamp < _tokenLocks[msg.sender]) {
      require(block.timestamp > _tokenLocks[msg.sender], "Tokens have yet to release");
    }
    
    

    if(block.timestamp > _tokenLocks[msg.sender] && _tokenLocks[msg.sender] != 0) {
      if(_tokenLocks[msg.sender] != 0) {
        delete _tokenLocks[msg.sender];
        emit TokensReleased(msg.sender, amount);
      }
    }
    super.transfer(recipient, amount);
  }

  function send(address recipient, uint256 amount, bytes memory data) public override {
    if(_tokenLocks[msg.sender] != 0 && block.timestamp < _tokenLocks[msg.sender]) {
      require(block.timestamp > _tokenLocks[msg.sender], "Tokens have yet to release");
    }
    
    if(block.timestamp > _tokenLocks[msg.sender] && _tokenLocks[msg.sender] != 0) {
      removeTokenLock(msg.sender, amount);
    }
      super.send(recipient, amount, data);
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
    uint unlockTime = block.timestamp + timeToLock;
    _tokenLocks[to] = unlockTime;
    uint256 toSend = amount * 10**18;
    send(to,toSend, "Locked Tokens");
    emit LockedTokensSent(to, toSend, unlockTime);
  }

  function removeTokenLock(address to, uint256 amount) public onlyOwner {
    if(_tokenLocks[to] != 0) {
      delete _tokenLocks[to];
      emit TokensReleased(to, amount);
    }
  }
}