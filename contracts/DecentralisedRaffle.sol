// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DecentralisedRaffle
 * @dev An advanced raffle smart contract with security features
 * @notice PART 2 - Decentralised Raffle (MANDATORY)
 */
contract DecentralisedRaffle {
    
    address public owner;
    uint256 public raffleId;
    uint256 public raffleStartTime;
    uint256 public totalEntries;
    uint256 public pot;
    bool public isPaused;
    bool private locked; 

    address[] public entries;

    address[] public players;
    mapping(address => bool) public hasEntered; 
    
    // TODO: Define additional state variables
    // Consider:
    // - How will you track entries?
    // - How will you store player information?
    // - What data structure for managing the pot?
    mapping(address => uint256) public playerEntries;
    mapping(address => mapping(uint256 => uint256)) public multipleEntries;
    
    constructor() {
        owner = msg.sender;
        raffleId = 1;
        raffleStartTime = block.timestamp;
        isPaused = false;
    }
    
    // TODO: Implement entry function
    // Requirements:
    // - Players pay minimum 0.01 ETH to enter
    // - Track each entry (not just unique addresses)
    // - Allow multiple entries per player
    // - Emit event with player address and entry count
    function enterRaffle() public payable {
        // Your implementation here
        // Validation: Check minimum entry amount
        // Validation: Check if raffle is active
        require(msg.value >= 0.01 ether, "Minimum entry amount is 0.01 ETH");
        require(!isPaused, "Raffle is paused");
        require(playerEntries[msg.sender] )

        playerEntries[msg.sender] += 1;
        totalEntries += 1;
        pot += msg.value;

        emit Entry(msg.sender, playerEntries[msg.sender]);

    }
    // TODO: Implement winner selection function
    // Requirements:
    // - Only owner can trigger
    // - Select winner from TOTAL entries (not unique players)
    // - Winner gets 90% of pot, owner gets 10% fee
    // - Use a secure random mechanism (better than block.timestamp)
    // - Require at least 3 unique players
    // - Require raffle has been active for 24 hours
    function selectWinner() public onlyOwner {
        // Your implementation here
        // CHALLENGE: How do you generate randomness securely?
        require(totalEntries >= 3, "At least 3 players required");
        require (block.timestamp >= raffleStartTime + 24 hours, "Raffle must be active for 24 hours");

        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, totalEntries)));
        uint256 winnerIndex = random % totalEntries;

        uint256 prize = (pot * 90) / 100;
        uint256 fee = pot - prize;
        
        payable(winner).transfer(prize);
        payable(owner).transfer(fee);
        
        pot = 0;
        totalEntries = 0;
    }
    
    // TODO: Implement circuit breaker (pause/unpause)
    // Requirements:
    // - Owner can pause raffle in emergency
    // - Owner can unpause raffle
    // - When paused, no entries allowed
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }
    
    function pause() public onlyOwner {
        // Your implementation
        isPaused = true;
    }
    
    function unpause() public onlyOwner {
        // Your implementation
        isPaused = false;
    }
    
    // TODO: Implement reentrancy protection
    // CRITICAL: Prevent reentrancy attacks when sending ETH
    
    // Use checks-effects-interactions pattern
    
    // TODO: Helper/View functions
    // - Get current pot balance
    // - Get player entry count
    // - Check if raffle is active
    // - Get unique player count
    
    // BONUS: Add multiple prize tiers (1st, 2nd, 3rd place)
    // BONUS: Add refund mechanism if minimum players not reached
}
