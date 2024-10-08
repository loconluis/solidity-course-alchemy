// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {console} from "forge-std/console.sol";

contract Voting {
    // Data struct Proposal
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }
    struct Voter {
        bool vote;
        uint proposalId;
        bool isVoter;
    }
    
    Proposal[] public proposals;
    address[] public allowed;
    mapping(address => Voter) public voters;
    mapping(uint => bool) public executionState;

    event ProposalCreated(uint);
    event VoteCast(uint, address);


    constructor(address[] memory list) {
        allowed = list;
        allowed.push(msg.sender);
    }

    function newProposal(address target, bytes calldata _data) external {
        proposals.push(Proposal(target, _data, 0, 0));
        emit ProposalCreated(proposals.length - 1);
    }

    function castVote(uint proposalId, bool vote) external OnlyMembers{
        bool alreadyVoter = voters[msg.sender].isVoter;
        bool hasChangeVote = !(voters[msg.sender].vote == vote);
        
        emit VoteCast(proposalId, msg.sender);

        if (alreadyVoter && hasChangeVote) {
            if (vote) {
                proposals[proposalId].yesCount++;
                proposals[proposalId].noCount--;
            } else {
                proposals[proposalId].yesCount--;
                proposals[proposalId].noCount++;
            }
        } else {
            addVoter(vote, proposalId);
            if (vote) {
                proposals[proposalId].yesCount++;
            } else {
                proposals[proposalId].noCount++;
            }
        }

        if (proposals[proposalId].yesCount > 9 && !executionState[proposalId]) {
            (bool s, ) = proposals[proposalId].target.call(proposals[proposalId].data);
            require(s);
            
            executionState[proposalId] = true;
        }
    }

    function addVoter(bool vote, uint proposalId) public  {
        voters[msg.sender].vote = vote;
        voters[msg.sender].proposalId = proposalId;
        voters[msg.sender].isVoter = true;
    }

    function isMember() public returns(bool){
        for(uint i = 0; i<allowed.length; i++) {
            if(allowed[i] == msg.sender) {
                return true;
            }
        }
    }

    modifier OnlyMembers(){
        require(isMember() == true);
        _;
    }

}
