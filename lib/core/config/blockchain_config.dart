class BlockchainConfig {
  // ✅ Contract address - DEPLOYED
  static const String contractAddress =
      '0x365d5d61596E2d1FaA9111c20C428009c69748cd';

  // Network configuration
  static const String rpcUrl = 'https://rpc-amoy.polygon.technology';
  static const int chainId = 80002;
  static const String networkName = 'Polygon Amoy Testnet';
  static const String currencySymbol = 'MATIC';
  static const String blockExplorerUrl = 'https://amoy.polygonscan.com';

  // Contract ABI (Application Binary Interface)
  // Simplified ABI for main functions
  static const String contractABI = '''[
    {
      "inputs": [
        {"name": "to", "type": "address"},
        {"name": "streakDays", "type": "uint256"},
        {"name": "metadataURI", "type": "string"}
      ],
      "name": "mintStreakBadge",
      "outputs": [{"type": "uint256"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"name": "to", "type": "address"},
        {"name": "workoutCount", "type": "uint256"},
        {"name": "metadataURI", "type": "string"}
      ],
      "name": "mintWorkoutBadge",
      "outputs": [{"type": "uint256"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"name": "user", "type": "address"}],
      "name": "getUserBadges",
      "outputs": [{"type": "uint256[]"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"name": "tokenId", "type": "uint256"}],
      "name": "getBadgeMetadata",
      "outputs": [
        {
          "type": "tuple",
          "components": [
            {"name": "badgeType", "type": "uint8"},
            {"name": "rarity", "type": "uint8"},
            {"name": "achievementValue", "type": "uint256"},
            {"name": "mintedAt", "type": "uint256"},
            {"name": "metadataURI", "type": "string"}
          ]
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "totalSupply",
      "outputs": [{"type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"name": "tokenId", "type": "uint256"}],
      "name": "ownerOf",
      "outputs": [{"type": "address"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"name": "tokenId", "type": "uint256"}],
      "name": "tokenURI",
      "outputs": [{"type": "string"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "name": "to", "type": "address"},
        {"indexed": true, "name": "tokenId", "type": "uint256"},
        {"indexed": false, "name": "badgeType", "type": "uint8"},
        {"indexed": false, "name": "rarity", "type": "uint8"},
        {"indexed": false, "name": "achievementValue", "type": "uint256"}
      ],
      "name": "BadgeMinted",
      "type": "event"
    }
  ]''';

  // Helper URLs
  static String getContractUrl() =>
      '$blockExplorerUrl/address/$contractAddress';

  static String getTransactionUrl(String txHash) =>
      '$blockExplorerUrl/tx/$txHash';

  static String getTokenUrl(int tokenId) =>
      '$blockExplorerUrl/token/$contractAddress?a=$tokenId';
}
