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


    function enterRaffle() public payable whenNotPaused {
        require(msg.value >= 0.01 ether, "Minimum entry is 0.01 ETH");

        if (!hasEntered[msg.sender]) {
            hasEntered[msg.sender] = true;
            players.push(msg.sender);
        }

        uint256 numEntries = msg.value / 0.01 ether;

        for (uint256 i = 0; i < numEntries; i++) {
            entries.push(msg.sender);
        }

        playerEntries[msg.sender] += numEntries;
        totalEntries += numEntries;
        pot += msg.value;

        emit Entry(msg.sender, playerEntries[msg.sender]);
    }

    function selectWinner() public onlyOwner noReentrant {
        require(players.length >= 3, "At least 3 unique players required");
        require( block.timestamp >= raffleStartTime + 24 hours, "Raffle must be active for 24 hours");

        uint256 random = uint256(keccak256(abi.encodePacked( block.prevrandao, block.timestamp, totalEntries, msg.sender) ));

        uint256 winnerIndex = random % entries.length;
        address winner = entries[winnerIndex];

        uint256 prize = (pot * 90) / 100;
        uint256 fee = pot - prize;

        uint256 currentRaffleId = raffleId;
        _resetRaffle();

        payable(winner).transfer(prize);
        payable(owner).transfer(fee);

        emit WinnerSelected(winner, prize, currentRaffleId);
    }


    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    function _resetRaffle() internal {
        raffleId++;
        raffleStartTime = block.timestamp;
        totalEntries = 0;
        pot = 0;
        delete entries;

        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            hasEntered[player] = false;
            playerEntries[player] = 0;
        }
        delete players;
    }
    
    function pause() public onlyOwner {
        isPaused = true;

        emit RafflePaused(msg.sender);
    }
    
    function unpause() public onlyOwner {
        isPaused = false;

        emit RaffleUnpaused(msg.sender);
    }


    function getPot() public view returns (uint256) {
        return pot;
    }

    function getPlayerEntryCount(address player) public view returns (uint256) {
        return playerEntries[player];
    }

    function isRaffleActive() public view returns (bool) {
        return !isPaused;
    }

    function getUniquePlayerCount() public view returns (uint256) {
        return players.length;
    }

    function getTotalEntries() public view returns (uint256) {
        return entries.length;
    }

}

