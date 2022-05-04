//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";

contract AuctionCreator {
    Auction[] public auctions;

    function createAuction() external {
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}
