// contracts/CoveyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoveyToken is ERC20, Ownable {
  uint256 public constant _maxSupply = 1_000_000 * 1e18;

  constructor() ERC20("Covey", "CVY")  {}

  function mint(
    address account,
    uint256 amount) public onlyOwner {
      require(totalSupply() + amount <= _maxSupply, "Token Minting cannot exceed Max Supply");
      _mint(account, amount);
  }
}