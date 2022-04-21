pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CoveyToken is ERC777, Ownable {

  struct Airdrop {
    address to;
    uint amount;
  }

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

  function isActive() view internal returns (bool) {
    return (
        balanceOf(address(this)) > 0
    );
  }

  function airdrop  (address[] memory recipients, uint256[] memory amounts) public _onlyOwnerOrOperators whenDropIsActive {
    for(uint i = 0; i < recipients.length; i++) {
      uint256 toSend = amounts[i] * 10**18;
      transferFrom(address(this),recipients[i], toSend);
    }
  }
}