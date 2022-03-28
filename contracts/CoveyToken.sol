pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract CoveyToken is ERC777 {
  constructor (uint initialSupply, address[] memory defaultOperators) ERC777("Covey", "CVY", defaultOperators) {
    _mint(msg.sender, initialSupply, "", "");
  }
}