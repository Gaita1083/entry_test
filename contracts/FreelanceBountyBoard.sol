// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title FreelanceBountyBoard
 * @dev A decentralised marketplace for skills and bounties
 * @notice PART 1 - Freelance Bounty Board (MANDATORY)
 */
contract FreelanceBountyBoard {
    
    // TODO: Define your state variables here
    // Consider:
    // - How will you track freelancers and their skills?
    // - How will you store bounty information?
    // - How will you manage payments?
    address public owner;
    uint256 public bountyIdCounter;
    bool private locked; 
    struct Freelancer {
        address freelancerAddress;
        string skill;
    }
    struct Bounty {
        uint256 id;
        address employer;
        string description;
        string skillRequired;
        uint256 reward;
        bool isOpen;
        address assignedFreelancer;
        string submissionUrl;
    }
    
    mapping(address => Freelancer) public freelancers;
    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(address => bool)) public hasApplied;

    enum bountyStatus { 
        Open,
        inProgress,
        Submitted,
        Completed,
        Disputed
    } 

    constructor() {
        owner = msg.sender;
    }  
    
    // TODO: Implement registerFreelancer function
    // Requirements:
    // - Freelancers should be able to register with their skill
    // - Prevent duplicate registrations
    // - Emit an event when a freelancer registers
    function registerFreelancer(string memory skill) public {
        // Your implementation here
    }
    
    // TODO: Implement postBounty function
    // Requirements:
    // - Employers post bounties with bounty (msg.value)
    // - Store bounty description and required skill
    // - Ensure ETH is sent with the transaction
    // - Emit an event when bounty is posted
    function postBounty(string memory description, string memory skillRequired) public payable {
        // Your implementation here
        // Think: How do you safely hold the ETH until work is approved?
    }
    
    // TODO: Implement applyForBounty function
    // Requirements:
    // - Freelancers can apply for bounties
    // - Check if freelancer has the required skill
    // - Prevent duplicate applications
    // - Emit an event
    function applyForBounty(uint256 bountyId) public {
        // Your implementation here
    }
    
    // TODO: Implement submitWork function
    // Requirements:
    // - Freelancers submit completed work (with proof/URL)
    // - Validate that freelancer applied for this bounty
    // - Update bounty status
    // - Emit an event
    function submitWork(uint256 bountyId, string memory submissionUrl) public {
        // Your implementation here
    }
    
    // TODO: Implement approveAndPay function
    // Requirements:
    // - Only employer who posted bounty can approve
    // - Transfer payment to freelancer
    // - CRITICAL: Implement reentrancy protection
    // - Update bounty status to completed
    // - Emit an event
    function approveAndPay(uint256 bountyId, address freelancer) public {
        // Your implementation here
        // Security: Use checks-effects-interactions pattern!
    }
    
    // BONUS: Implement dispute resolution
    // What happens if employer doesn't approve but work is done?
    // Consider implementing a timeout mechanism
    
    // Helper functions you might need:
    // - Function to get bounty details
    // - Function to check freelancer registration
    // - Function to get all bounties
}
