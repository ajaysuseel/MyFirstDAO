//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MyFirstDAO
{
    struct Proposal{
        string description;
        uint voteCount;
        uint yesVotes;
        uint noVotes;
        bool executed;
    }

    struct Member{
        address memberAddress;
        uint memberSince;
        uint tokenbalance;

    }
    //Global variables
    address[] public members;
    mapping(address=>bool) public isMember;
    mapping(address=>Member) public memberInfo;
    mapping(address=>mapping(uint=>bool)) public votes;
    Proposal[] public proposals;
    uint public totalSupply;
    mapping(address=>uint) public balance;

    //events
    event ProposalCreated(uint indexed proposalId,string description);
    event VoteCast(address indexed voter,uint indexed proposalId,uint tokenAmount);
    event proposalAccepted(string message);
    event proposalRejected(string rejected);

    //Contract building.....
    address public owner;
    constructor(){
        owner=msg.sender;
    }
    //Basic functions
    function addMember(address _member) public{
        require(msg.sender==owner);
        require(isMember[_member]==false,"Member already exists");
        memberInfo[_member]=Member({memberAddress:_member,
        memberSince:block.timestamp,
        tokenbalance:100});

        members.push(_member);
        isMember[_member]=true;
        balance[_member]=100;
        totalSupply+=100;
    }
        
    function removeMember(address _member) public{
        require(msg.sender==owner);
        require(isMember[_member]==true,"Member does not exist");
        memberInfo[_member]=Member({memberAddress:address(0),
        memberSince:0,
        tokenbalance:0});

        for(uint i=0;i<members.length;i++)
        {
            if(members[i]==_member)
            {
                members[i]=members[members.length-1];
                members.pop();
                break;
            }
        }
        isMember[_member]=false;
        balance[_member]=0;
        totalSupply-=100;
    }
    //Voting system
    function createProposal(string memory _description) public{
        proposals.push(Proposal({
             description:_description,
             voteCount:0,
             yesVotes:0,
             noVotes:0,
             executed:false
        }));
        emit ProposalCreated(proposals.length-1,_description);
    }
    
    function  voteYes(uint _proposalId,uint _tokenAmount) public{
        require(isMember[msg.sender]==true,"You need to be a member to vote!");
        require(balance[msg.sender]>=_tokenAmount,"Insufficient Token Amount!");
        require(votes[msg.sender][_proposalId]==false,"You have already voted!");
        votes[msg.sender][_proposalId]=true;
        memberInfo[msg.sender].tokenbalance-=_tokenAmount;
        proposals[_proposalId].voteCount+=_tokenAmount;
        proposals[_proposalId].yesVotes+=_tokenAmount;
        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }
    function  voteNo(uint _proposalId,uint _tokenAmount) public{
        require(isMember[msg.sender]==true,"You need to be a member to vote!");
        require(balance[msg.sender]>=_tokenAmount,"Insufficient Token Amount!");
        require(votes[msg.sender][_proposalId]==false,"You have already voted!");
        votes[msg.sender][_proposalId]=true;
        memberInfo[msg.sender].tokenbalance-=_tokenAmount;
        proposals[_proposalId].voteCount+=_tokenAmount;
        proposals[_proposalId].noVotes+=_tokenAmount;
        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }
    
    function executeProposal(uint _proposalId) public{
        require(proposals[_proposalId].executed==false,"Proposal already executed");
        require(proposals[_proposalId].yesVotes>proposals[_proposalId].noVotes,"Not enough votes to approve proposal");
        proposals[_proposalId].executed=true;
        emit proposalAccepted("Proposal is approved");
    }

}