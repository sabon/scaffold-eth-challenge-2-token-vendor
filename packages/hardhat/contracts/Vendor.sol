pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;

  // Token price: how many tokens per ETH
  uint256 public tokensPerEth = 100;
  uint256 public pricePerToken = 0.01 ether;


  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // Payable function to buy tokens from YourToken contract
  function buyTokens() public payable {
    require(msg.value > 0, "Send some ETH.");

    // Frontend passess the value of ETH to this function, not the number of tokens, so we need to convert it first
    uint256 amountOfTokens = msg.value * tokensPerEth;

    // Check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountOfTokens, "There is not enough tokens.");

    // Transfer tokens to msg.sender
    require(yourToken.transfer(msg.sender, amountOfTokens), "Failed to transfer tokens.");

    // Emit the event
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);

  }

  // Allow the owner to withdraw ETH. No arguments needed - withdraws all ETH by default
  function withdraw() public onlyOwner {
    // Check if there's any ETH to withdraw
    require(address(this).balance > 0, "There's no ETH to withdraw.");

    // Withdraw all ETH
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send ETH.");
  }

  // ToDo: create a sellTokens() function:

}
