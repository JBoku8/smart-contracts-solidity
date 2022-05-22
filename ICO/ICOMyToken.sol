
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../Token/MyToken.sol";

contract MyTokenICO is MyToken {
    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.001 ether;
    uint public hardCap = 300 ether;
    uint public raisedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800;
    uint public tradeStart = saleEnd + 604800;

    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;

    enum State  {
        beforeStart,
        running,
        afterEnd,
        halted
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() external onlyAdmin {
        icoState = State.halted;
    }

    function resume() external onlyAdmin {
        icoState = State.running;
    }

    function changeDepositAddress(address payable _deposit) external onlyAdmin {
        deposit = _deposit;
    }

    function getCurrentState() public view returns(State) {
        if( icoState == State.halted ) {
            return State.halted;
        }
        else if ( block.timestamp < saleStart) {
            return State.beforeStart;
        }
        else if( block.timestamp >= saleStart && block.timestamp <= saleEnd ) {
            return State.running;
        }
        else {
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint value, uint tokens);

    function invest() public payable returns(bool) {
        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment || msg.value <= maxInvestment);

        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;

        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    receive() payable external {
        invest();
    }

    function transfer(address to, uint256 value) public override returns (bool success) {
        require(block.timestamp >= tradeStart);
        CryptoBoku.transfer(to, value); // super.transfer
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
        require(block.timestamp >= tradeStart);
        CryptoBoku.transferFrom(from, to, value);
        return true;
    }


    function burn() public returns(bool) {
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }

}