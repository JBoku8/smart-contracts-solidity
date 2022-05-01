// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;

        players.push(payable(msg.sender));
    }

    receive() external payable {
        require(msg.sender != manager);
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "You are not allowed to see the balance.");
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public {
        require(msg.sender == manager);
        require(players.length >= 10);

        uint r = random();
        address payable winner;
        uint index = r % players.length;

        winner = players[index];

        uint managerFee = (getBalance() * 10 ) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90 ) / 100;     // winner prize is 90%

        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);

        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);

        // resetting the lottery for the next round
        players = new address payable[](0);
    }

}