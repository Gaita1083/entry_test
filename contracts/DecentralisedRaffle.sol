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

    event Entry(address indexed player, uint256 totalPlayerEntries);
    event WinnerSelected(address indexed winner, uint256 prize, uint256 raffleId);
    event RafflePaused(address indexed by);
    event RaffleUnpaused(address indexed by);
    
    constructor() {
        owner = msg.sender;
        raffleId = 1;
        raffleStartTime = block.timestamp;
        isPaused = false;
        locked = false;
    }
    
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
    // TODO: Implement winner selection function
    // Requirements:
    // - Only owner can trigger
    // - Select winner from TOTAL entries (not unique players)
    // - Winner gets 90% of pot, owner gets 10% fee
    // - Use a secure random mechanism (better than block.timestamp)
    // - Require at least 3 unique players
    // - Require raffle has been active for 24 hours
    function selectWinner() public onlyOwner noReentrant {
        // Your implementation here
        // CHALLENGE: How do you generate randomness securely?
        require(players.length >= 3, "At least 3 unique players required");
        require(block.timestamp >= raffleStartTime + 24 hours, "Raffle must be active for 24 hours");

        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, totalEntries)));
        uint256 winnerIndex = random % totalEntries;

        uint256 prize = (pot * 90) / 100;
        uint256 fee = pot - prize;
        
        uint256 winnerIndex = random % entries.length;
        address winner = entries[winnerIndex];

        
        uint256 currentRaffleId = raffleId;
        _resetRaffle();

        payable(winner).transfer(prize);
        payable(owner).transfer(fee);

        emit WinnerSelected(winner, prize, currentRaffleId);
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

        emit RafflePaused(msg.sender);
    }
    
    function unpause() public onlyOwner {
        // Your implementation
        isPaused = false;

        emit RaffleUnpaused(msg.sender);
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
