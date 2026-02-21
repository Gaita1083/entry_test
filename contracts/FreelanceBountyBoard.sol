// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title FreelanceBountyBoard
 * @dev A decentralised marketplace for skills and bounties
 * @notice PART 1 - Freelance Bounty Board (MANDATORY)
 */
contract FreelanceBountyBoard {

    address public owner;
    uint256 public bountyCount;
    bool private locked;

    struct Freelancer {
        bool isRegistered;
        string skill;
    }

    struct Bounty {
        uint256 id;
        address employer;
        string description;
        string skillRequired;
        uint256 payment;
        BountyStatus status;
        address assignedFreelancer;
        string submissionUrl;
        uint256 postedAt;
    }

    mapping(address => Freelancer) public freelancers;
    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(address => bool)) public hasApplied;

    enum BountyStatus {
        Open,
        InProgress,
        Submitted,
        Completed,
        Disputed
    }

    event FreelancerRegistered(address indexed freelancer, string skill);
    event BountyPosted(uint256 indexed bountyId, address indexed employer, uint256 payment, string skillRequired);
    event AppliedForBounty(uint256 indexed bountyId, address indexed freelancer);
    event WorkSubmitted(uint256 indexed bountyId, address indexed freelancer, string submissionUrl);
    event BountyCompleted(uint256 indexed bountyId, address indexed freelancer, uint256 payment);
    event BountyDisputed(uint256 indexed bountyId, address indexed raisedBy);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyRegistered() {
        require(freelancers[msg.sender].isRegistered, "Not a registered freelancer");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerFreelancer(string memory skill) public {
        require(!freelancers[msg.sender].isRegistered, "Already registered");
        require(bytes(skill).length > 0, "Skill cannot be empty");

        freelancers[msg.sender] = Freelancer({
            isRegistered: true,
            skill: skill
        });

        emit FreelancerRegistered(msg.sender, skill);
    }

    function postBounty(string memory description, string memory skillRequired) public payable {
        require(msg.value > 0, "Must send ETH as payment");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(skillRequired).length > 0, "Skill required cannot be empty");

        bountyCount += 1;

        bounties[bountyCount] = Bounty({
            id: bountyCount,
            employer: msg.sender,
            description: description,
            skillRequired: skillRequired,
            payment: msg.value,
            status: BountyStatus.Open,
            assignedFreelancer: address(0),
            submissionUrl: "",
            postedAt: block.timestamp
        });

        emit BountyPosted(bountyCount, msg.sender, msg.value, skillRequired);
    }

    function applyForBounty(uint256 bountyId) public onlyRegistered {
        Bounty storage bounty = bounties[bountyId];

        require(bounty.id != 0, "Bounty does not exist");
        require(bounty.status == BountyStatus.Open, "Bounty is not open");
        require(!hasApplied[bountyId][msg.sender], "Already applied");
        require(
            keccak256(bytes(freelancers[msg.sender].skill)) == keccak256(bytes(bounty.skillRequired)),
            "Your skill does not match the required skill"
        );
        require(msg.sender != bounty.employer, "Employer cannot apply to own bounty");

        hasApplied[bountyId][msg.sender] = true;

        bounty.assignedFreelancer = msg.sender;
        bounty.status = BountyStatus.InProgress;

        emit AppliedForBounty(bountyId, msg.sender);
    }

    function submitWork(uint256 bountyId, string memory submissionUrl) public {
        Bounty storage bounty = bounties[bountyId];

        require(bounty.id != 0, "Bounty does not exist");
        require(bounty.assignedFreelancer == msg.sender, "You are not assigned to this bounty");
        require(bounty.status == BountyStatus.InProgress, "Bounty is not in progress");
        require(bytes(submissionUrl).length > 0, "Submission URL cannot be empty");

        bounty.submissionUrl = submissionUrl;
        bounty.status = BountyStatus.Submitted;

        emit WorkSubmitted(bountyId, msg.sender, submissionUrl);
    }

    function approveAndPay(uint256 bountyId, address freelancer) public noReentrant {
        Bounty storage bounty = bounties[bountyId];

        require(bounty.id != 0, "Bounty does not exist");
        require(msg.sender == bounty.employer, "Only the employer can approve");
        require(bounty.status == BountyStatus.Submitted, "Work has not been submitted yet");
        require(bounty.assignedFreelancer == freelancer, "Wrong freelancer address");

        uint256 payment = bounty.payment;

        bounty.status = BountyStatus.Completed;
        bounty.payment = 0;

        (bool sent, ) = payable(freelancer).call{value: payment}("");
        require(sent, "Payment transfer failed");

        emit BountyCompleted(bountyId, freelancer, payment);
    }

    function raiseDispute(uint256 bountyId) public noReentrant {
        Bounty storage bounty = bounties[bountyId];

        require(bounty.id != 0, "Bounty does not exist");
        require(bounty.assignedFreelancer == msg.sender, "Only assigned freelancer can raise dispute");
        require(bounty.status == BountyStatus.Submitted, "Work must be submitted first");
        require(
            block.timestamp >= bounty.postedAt + 7 days,
            "Must wait 7 days after submission before raising dispute"
        );

        uint256 payment = bounty.payment;

        bounty.status = BountyStatus.Disputed;
        bounty.payment = 0;

        (bool sent, ) = payable(msg.sender).call{value: payment}("");
        require(sent, "Dispute payment transfer failed");

        emit BountyDisputed(bountyId, msg.sender);
    }

    function getBounty(uint256 bountyId) public view returns (Bounty memory) {
        require(bounties[bountyId].id != 0, "Bounty does not exist");
        return bounties[bountyId];
    }

    function isFreelancerRegistered(address freelancer) public view returns (bool) {
        return freelancers[freelancer].isRegistered;
    }

    function getFreelancerSkill(address freelancer) public view returns (string memory) {
        require(freelancers[freelancer].isRegistered, "Freelancer not registered");
        return freelancers[freelancer].skill;
    }

    function getAllBounties() public view returns (Bounty[] memory) {
        Bounty[] memory all = new Bounty[](bountyCount);
        for (uint256 i = 1; i <= bountyCount; i++) {
            all[i - 1] = bounties[i];
        }
        return all;
    }

    function getOpenBounties() public view returns (Bounty[] memory) {
        uint256 openCount = 0;
        for (uint256 i = 1; i <= bountyCount; i++) {
            if (bounties[i].status == BountyStatus.Open) {
                openCount++;
            }
        }

        Bounty[] memory open = new Bounty[](openCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= bountyCount; i++) {
            if (bounties[i].status == BountyStatus.Open) {
                open[index] = bounties[i];
                index++;
            }
        }
        return open;
    }
}