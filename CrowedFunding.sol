//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract CrowedFunding{
    mapping(address => uint ) public contributors;
    address public Manager;
    uint public minimunAmount;
    uint public Deadline;
    uint public Target;
    uint public RaiseAmount;
    uint public Noofcontributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequest;

    constructor(uint _Target,uint _Deadline){
        Target = _Target;
        Deadline = block.timestamp + _Deadline;
        minimunAmount = 100 wei;
        Manager = msg.sender;
    }

    function SendEather () public payable {
        require(block.timestamp < Deadline , 'Time is up for the contribution');
        require(msg.value >= minimunAmount , 'Atleat 100 wei not less then that');

        if (contributors [msg.sender] == 0 ){
            Noofcontributors ++;
        }
        contributors[msg.sender] += msg.value;
        RaiseAmount+= msg.value;
    }

    function getcontractbalance() public  view  returns (uint) {
        return address(this).balance;
    }
    function  refund () public {
        require (block.timestamp>Deadline && RaiseAmount<Target , "You are not eligible for the refund");
        require(contributors[msg.sender]>0);
        address payable user =payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] =0;
    }

    modifier onlyManger(){
        require(msg.sender==Manager,"Only manager can calll this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManger{
        Request storage newRequest = requests[numRequest];
        numRequest++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0,"YOu must be contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;

    }
    function makePayment(uint _requestNo) public onlyManger{
        require(RaiseAmount>=Target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > Noofcontributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }


}