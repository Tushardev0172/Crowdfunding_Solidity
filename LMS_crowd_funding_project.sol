// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
contract crowd_funding
{
    mapping(address=>uint) public  Contributors;
    address public Manager;
    uint public MinimumContribution;
    uint public Deadline;
    uint public Target;
    uint public CollectedAmount;
    uint public NoOfContributors;

    struct RequestAmount
    {
        string Description;
        address payable Recipient;
        uint ValueOfAmount;
        bool isAmountRecieved;
        uint NoOfVoters;
        mapping(address=>bool) Voters;
    }

    mapping(uint=>RequestAmount) public RequestAmounts;
    uint public NoOfRequestedAmounts;

    constructor(uint _Target, uint _Deadline)
    {
        Target = _Target;
        Deadline = block.timestamp + _Deadline;
        MinimumContribution = 100 wei;
        Manager = msg.sender;
    }

    function SendEther() public payable 
    {
        require(block.timestamp < Deadline, "Deadline has passed");
        require(msg.value >= MinimumContribution, " Minimum Contribution is not met");

        if(Contributors[msg.sender] ==0)
        {
            NoOfContributors++;
        }

        Contributors[msg.sender]=Contributors[msg.sender]+msg.value;
        CollectedAmount=CollectedAmount + msg.value;
    }

    function getContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    function RefundAmount() public 
    {
        require(block.timestamp < Deadline && CollectedAmount < Target,"The contributor is not eligable for refund");
        require(Contributors[msg.sender] > 0);
        address payable User = payable(msg.sender);
        User.transfer(Contributors[msg.sender]);
        Contributors[msg.sender]=0;
    }

    modifier OnlyManager()
    {
        require(msg.sender==Manager,"Only manager can call this Function");
        _;
    }


    
    function CreatorRequest(string memory _Description,address payable _Recipient,uint _ValueOfAmount) public OnlyManager
    {
        RequestAmount storage NewRequest = RequestAmounts[NoOfRequestedAmounts];
        NoOfRequestedAmounts++;
        NewRequest.Description = _Description;
        NewRequest.Recipient = _Recipient;
        NewRequest.ValueOfAmount = _ValueOfAmount;
        NewRequest.isAmountRecieved = false;
        NewRequest.NoOfVoters = 0;
    }

    function VoteRequest(uint _RequestNo) public 
    {
        require(Contributors[msg.sender] > 0,"You must be a contributor to Vote the type of request");
        RequestAmount storage ThisVoteRequest = RequestAmounts[_RequestNo];
        require(ThisVoteRequest.Voters[msg.sender]==false,"You have already voted");
        ThisVoteRequest.Voters[msg.sender] = true;
        ThisVoteRequest.NoOfVoters++;   
    }

    function MakePayment(uint _RequestNo) public OnlyManager
    {
        require(CollectedAmount>=Target);
        RequestAmount storage ThisVoteRequest = RequestAmounts[_RequestNo];
        require(ThisVoteRequest.NoOfVoters > NoOfContributors/2,"Majority of Contributors does not support");
        ThisVoteRequest.Recipient.transfer(ThisVoteRequest.ValueOfAmount);
        ThisVoteRequest.isAmountRecieved = true;
    }
    
    }