//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC20.sol";

contract MyToken is IERC20 {
    string public name = "Token Example";
    string public symbol = "TEMP";
    uint public decimals = 0; // 18
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return balances[who];
    }

    function transfer(address to, uint256 value)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= value);

        balances[to] += value;
        balances[msg.sender] -= value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 value)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= value);
        require(value > 0);

        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool success) {
        require(allowed[from][msg.sender] >= value);
        require(balances[from] >= value);

        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        balances[to] += value;

        emit Transfer(from, to, value);

        return true;
    }
}
