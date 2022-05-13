//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract CrowdFunding {
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    mapping(address => uint256) public contributors;
    uint256 public numberOfContributors;
    address public admin;
    uint256 public minimumContribution;
    uint256 public deadline; // timestamp
    uint256 public goal;
    uint256 public raisedAmount;

    struct Request {
        string description;
        address payable recepient;
        uint256 value;
        uint256 noOfVoters;
        bool completed;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Request) public requests;
    uint256 public requestCount;

    // events to emit
    event ContributeEvent(address _sender, uint256 _value);
    event CreateRequestEvent(
        string _description,
        address _recipient,
        uint256 _value
    );
    event MakePaymentEvent(address _recipient, uint256 _value);

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100; // wei
        admin = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed!");
        require(
            msg.value >= minimumContribution,
            "Minimum contribution is not met!."
        );

        if (contributors[msg.sender] == 0) {
            numberOfContributors++;
        }

        contributors[msg.sender] = msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    function getBalanace() public view returns (uint256) {
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp < deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        address payable recepient = payable(msg.sender);
        uint256 value = contributors[msg.sender];
        contributors[msg.sender] = 0;
        recepient.transfer(value);
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyAdmin {
        Request storage newRequest = requests[requestCount];
        requestCount++;

        newRequest.value = _value;
        newRequest.recepient = _recipient;
        newRequest.description = _description;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint256 requestNumber) public {
        require(contributors[msg.sender] > 0, "Only congtributors can vote.");
        Request storage request = requests[requestNumber];

        require(request.voters[msg.sender] == false, "You have already voted.");
        request.voters[msg.sender] = true;
        request.noOfVoters++;
    }

    function makePayment(uint256 requestNumber) public onlyAdmin {
        require(raisedAmount >= goal, "goal is not reached.");
        Request storage request = requests[requestNumber];
        require(
            requests[requestNumber].completed == false,
            "The request is completed already."
        );
        require(request.noOfVoters > numberOfContributors / 2);

        request.completed = true;
        request.recepient.transfer(request.value);

        emit MakePaymentEvent(request.recepient, request.value);
    }

    receive() external payable {
        contribute();
    }
}
