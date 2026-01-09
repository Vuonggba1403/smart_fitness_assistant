// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FitnessNFT
 * @dev NFT contract for Smart Fitness Assistant achievement badges
 * Supports streak milestones and workout completion badges
 */
contract FitnessNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    // Badge types
    enum BadgeType {
        STREAK_MILESTONE,
        WORKOUT_COMPLETION,
        SPECIAL_ACHIEVEMENT
    }

    // Badge rarity levels
    enum BadgeRarity {
        COMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    // Badge metadata structure
    struct BadgeMetadata {
        BadgeType badgeType;
        BadgeRarity rarity;
        uint256 achievementValue; // streak days or workout count
        uint256 mintedAt;
        string metadataURI;
    }

    // Mapping from token ID to badge metadata
    mapping(uint256 => BadgeMetadata) public badges;
    
    // Mapping from user address to their badge IDs
    mapping(address => uint256[]) public userBadges;
    
    // Mapping to prevent duplicate streak badges
    mapping(address => mapping(uint256 => bool)) public hasStreakBadge;

    // Events
    event BadgeMinted(
        address indexed to,
        uint256 indexed tokenId,
        BadgeType badgeType,
        BadgeRarity rarity,
        uint256 achievementValue
    );

    constructor() ERC721("Fitness Achievement NFT", "FITNFT") Ownable(msg.sender) {}

    /**
     * @dev Mint a streak milestone badge
     * @param to Address to mint badge to
     * @param streakDays Number of consecutive workout days
     * @param metadataURI IPFS URI for badge metadata
     */
    function mintStreakBadge(
        address to,
        uint256 streakDays,
        string memory metadataURI
    ) public onlyOwner returns (uint256) {
        require(!hasStreakBadge[to][streakDays], "Streak badge already minted");
        
        uint256 newTokenId = _tokenIds;
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, metadataURI);

        BadgeRarity rarity = _getStreakRarity(streakDays);
        
        badges[newTokenId] = BadgeMetadata({
            badgeType: BadgeType.STREAK_MILESTONE,
            rarity: rarity,
            achievementValue: streakDays,
            mintedAt: block.timestamp,
            metadataURI: metadataURI
        });

        userBadges[to].push(newTokenId);
        hasStreakBadge[to][streakDays] = true;
        
        _tokenIds++;

        emit BadgeMinted(to, newTokenId, BadgeType.STREAK_MILESTONE, rarity, streakDays);
        
        return newTokenId;
    }

    /**
     * @dev Mint a workout completion badge
     * @param to Address to mint badge to
     * @param workoutCount Total workouts completed
     * @param metadataURI IPFS URI for badge metadata
     */
    function mintWorkoutBadge(
        address to,
        uint256 workoutCount,
        string memory metadataURI
    ) public onlyOwner returns (uint256) {
        uint256 newTokenId = _tokenIds;
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, metadataURI);

        BadgeRarity rarity = _getWorkoutRarity(workoutCount);
        
        badges[newTokenId] = BadgeMetadata({
            badgeType: BadgeType.WORKOUT_COMPLETION,
            rarity: rarity,
            achievementValue: workoutCount,
            mintedAt: block.timestamp,
            metadataURI: metadataURI
        });

        userBadges[to].push(newTokenId);
        
        _tokenIds++;

        emit BadgeMinted(to, newTokenId, BadgeType.WORKOUT_COMPLETION, rarity, workoutCount);
        
        return newTokenId;
    }

    /**
     * @dev Get all badges owned by an address
     */
    function getUserBadges(address user) public view returns (uint256[] memory) {
        return userBadges[user];
    }

    /**
     * @dev Get badge metadata
     */
    function getBadgeMetadata(uint256 tokenId) public view returns (BadgeMetadata memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return badges[tokenId];
    }

    /**
     * @dev Determine rarity based on streak days
     */
    function _getStreakRarity(uint256 streakDays) private pure returns (BadgeRarity) {
        if (streakDays >= 365) return BadgeRarity.LEGENDARY;
        if (streakDays >= 100) return BadgeRarity.EPIC;
        if (streakDays >= 30) return BadgeRarity.RARE;
        return BadgeRarity.COMMON;
    }

    /**
     * @dev Determine rarity based on workout count
     */
    function _getWorkoutRarity(uint256 count) private pure returns (BadgeRarity) {
        if (count >= 500) return BadgeRarity.LEGENDARY;
        if (count >= 200) return BadgeRarity.EPIC;
        if (count >= 50) return BadgeRarity.RARE;
        return BadgeRarity.COMMON;
    }

    /**
     * @dev Get total supply of minted badges
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIds;
    }

    /**
     * @dev Override transfer to update user badges mapping
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = super._update(to, tokenId, auth);
        
        if (from != address(0) && from != to) {
            _removeFromUserBadges(from, tokenId);
        }
        
        if (to != address(0) && from != to) {
            userBadges[to].push(tokenId);
        }
        
        return from;
    }

    /**
     * @dev Remove badge from user's array
     */
    function _removeFromUserBadges(address user, uint256 tokenId) private {
        uint256[] storage badges = userBadges[user];
        for (uint256 i = 0; i < badges.length; i++) {
            if (badges[i] == tokenId) {
                badges[i] = badges[badges.length - 1];
                badges.pop();
                break;
            }
        }
    }
}
