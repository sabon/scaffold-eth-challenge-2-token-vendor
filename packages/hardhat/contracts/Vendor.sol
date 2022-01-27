pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;

  // Token price: how many tokens per ETH
  uint256 public tokensPerEth = 100;

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

  // Sell tokens to the Vendor Contract
  function sellTokens(uint256 _amountOfTokens) public {
    require(_amountOfTokens > 0, "You've just sold 0 tokens for 0 ETH! If you want to get more ETH, try selling more than 0 tokens.");

    // Check if the msg.sender has enough tokens
    uint256 userTokens = yourToken.balanceOf(msg.sender);
    require(userTokens >= _amountOfTokens, "You're trying to send more tokens than you have.");

    // Check if Vendor has enough ETH to pay for the tokens
    uint256 amountOfETHToPay = _amountOfTokens / tokensPerEth;
    uint256 vendorETHBalance = address(this).balance;
    require(vendorETHBalance >= amountOfETHToPay, "There's not enough funds to pay for this amount of tokens.");

    // Transfer tokens to Vendor
    require(yourToken.transferFrom(msg.sender, address(this), _amountOfTokens), "Failed to transfer tokens.");
    // Transfer ETH to the user
    (bool sent,) = msg.sender.call{value: amountOfETHToPay}("");
    require(sent, "Failed to send ETH.");

    // Emit the sell event
    emit SellTokens(msg.sender, amountOfETHToPay, _amountOfTokens);
  }
}
