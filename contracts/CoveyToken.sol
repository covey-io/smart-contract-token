// contracts/CoveyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoveyToken is ERC20 {
  constructor(uint initialSupply) ERC20("Covey", "CVY")  {
    _mint(msg.sender, initialSupply);
  }
}