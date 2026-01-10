import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:smart_fitness_assistant/core/config/blockchain_config.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';

/// Service for interacting with FitnessNFT smart contract on Polygon
///
/// Handles:
/// - Minting NFT badges (streak & workout achievements)
/// - Reading user's NFT collection
/// - Querying badge metadata
class BlockchainService {
  // Singleton pattern
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // Web3 client
  late Web3Client _client;
  late DeployedContract _contract;

  // Contract functions
  late ContractFunction _mintStreakBadge;
  late ContractFunction _mintWorkoutBadge;
  late ContractFunction _getUserBadges;
  late ContractFunction _getBadgeMetadata;
  late ContractFunction _totalSupply;
  late ContractFunction _ownerOf;
  late ContractFunction _tokenURI;

  bool _initialized = false;

  /// Initialize blockchain service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Starting blockchain initialization...');

      // Debug: Check config values
      print('📍 Contract Address: ${BlockchainConfig.contractAddress}');
      print('🌐 RPC URL: ${BlockchainConfig.rpcUrl}');
      print('🔢 Chain ID: ${BlockchainConfig.chainId}');

      // Create HTTP client for RPC calls
      print('🔄 Creating Web3 client...');
      _client = Web3Client(BlockchainConfig.rpcUrl, Client());
      print('✅ Web3 client created');

      // Parse contract ABI
      print('🔄 Parsing contract ABI...');
      print('📄 ABI length: ${BlockchainConfig.contractABI.length} chars');
      final abiJson = jsonDecode(BlockchainConfig.contractABI) as List;
      print('✅ ABI parsed: ${abiJson.length} entries');

      // Create contract instance
      print('🔄 Creating contract instance...');
      _contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abiJson), 'FitnessNFT'),
        EthereumAddress.fromHex(BlockchainConfig.contractAddress),
      );
      print('✅ Contract instance created');

      // Initialize contract functions
      print('🔄 Loading contract functions...');
      _mintStreakBadge = _contract.function('mintStreakBadge');
      _mintWorkoutBadge = _contract.function('mintWorkoutBadge');
      _getUserBadges = _contract.function('getUserBadges');
      _getBadgeMetadata = _contract.function('getBadgeMetadata');
      _totalSupply = _contract.function('totalSupply');
      _ownerOf = _contract.function('ownerOf');
      _tokenURI = _contract.function('tokenURI');
      print('✅ Contract functions loaded');

      _initialized = true;
      print('✅ BlockchainService initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error initializing BlockchainService: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Mint a streak milestone NFT badge
  ///
  /// [userAddress] - User's wallet address
  /// [streakDays] - Number of consecutive workout days (7, 14, 30, 50, 100, 365)
  /// [privateKey] - Private key for signing transaction (owner only)
  ///
  /// Returns the token ID of minted NFT
  Future<int> mintStreakBadge({
    required String userAddress,
    required int streakDays,
    required String privateKey,
  }) async {
    await initialize();

    try {
      print('🔄 Minting streak badge: $streakDays days for $userAddress');

      // Create metadata URI (for now, simple string - can upgrade to IPFS later)
      final metadataURI =
          'data:application/json,{"name":"$streakDays-Day Streak","achievement":"$streakDays consecutive workouts"}';

      // Prepare credentials
      final credentials = EthPrivateKey.fromHex(privateKey);
      final to = EthereumAddress.fromHex(userAddress);

      // Send transaction
      final txHash = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: _mintStreakBadge,
          parameters: [to, BigInt.from(streakDays), metadataURI],
        ),
        chainId: BlockchainConfig.chainId,
      );

      print('📋 Transaction sent: $txHash');

      // Wait for transaction confirmation
      TransactionReceipt? receipt;
      int attempts = 0;
      while (receipt == null && attempts < 30) {
        await Future.delayed(const Duration(seconds: 2));
        receipt = await _client.getTransactionReceipt(txHash);
        attempts++;
      }

      if (receipt == null) {
        throw Exception('Transaction timeout');
      }

      print('✅ Streak badge minted! TX: $txHash');

      // Parse token ID from logs (simplified - assumes sequential minting)
      final totalSupply = await getTotalSupply();
      return totalSupply - 1; // Latest minted token
    } catch (e) {
      print('❌ Error minting streak badge: $e');
      rethrow;
    }
  }

  /// Mint a workout completion NFT badge
  Future<int> mintWorkoutBadge({
    required String userAddress,
    required int workoutCount,
    required String privateKey,
  }) async {
    await initialize();

    try {
      print(
        '🔄 Minting workout badge: $workoutCount workouts for $userAddress',
      );

      final metadataURI =
          'data:application/json,{"name":"$workoutCount Workouts","achievement":"Completed $workoutCount workout sessions"}';

      final credentials = EthPrivateKey.fromHex(privateKey);
      final to = EthereumAddress.fromHex(userAddress);

      final txHash = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: _mintWorkoutBadge,
          parameters: [to, BigInt.from(workoutCount), metadataURI],
        ),
        chainId: BlockchainConfig.chainId,
      );

      print('📋 Transaction sent: $txHash');

      // Wait for confirmation
      TransactionReceipt? receipt;
      int attempts = 0;
      while (receipt == null && attempts < 30) {
        await Future.delayed(const Duration(seconds: 2));
        receipt = await _client.getTransactionReceipt(txHash);
        attempts++;
      }

      if (receipt == null) {
        throw Exception('Transaction timeout');
      }

      print('✅ Workout badge minted! TX: $txHash');

      final totalSupply = await getTotalSupply();
      return totalSupply - 1;
    } catch (e) {
      print('❌ Error minting workout badge: $e');
      rethrow;
    }
  }

  /// Get all NFT badges owned by a user
  ///
  /// Returns list of token IDs
  Future<List<int>> getUserBadges(String userAddress) async {
    await initialize();

    try {
      final result = await _client.call(
        contract: _contract,
        function: _getUserBadges,
        params: [EthereumAddress.fromHex(userAddress)],
      );

      final tokenIds = (result.first as List)
          .map((id) => (id as BigInt).toInt())
          .toList();

      print('✅ Found ${tokenIds.length} badges for $userAddress');
      return tokenIds;
    } catch (e) {
      print('❌ Error getting user badges: $e');
      return [];
    }
  }

  /// Get badge metadata from blockchain
  Future<Map<String, dynamic>?> getBadgeMetadata(int tokenId) async {
    await initialize();

    try {
      final result = await _client.call(
        contract: _contract,
        function: _getBadgeMetadata,
        params: [BigInt.from(tokenId)],
      );

      // Parse tuple result
      final metadata = result.first as List;

      return {
        'badgeType': (metadata[0] as BigInt).toInt(),
        'rarity': (metadata[1] as BigInt).toInt(),
        'achievementValue': (metadata[2] as BigInt).toInt(),
        'mintedAt': DateTime.fromMillisecondsSinceEpoch(
          (metadata[3] as BigInt).toInt() * 1000,
        ),
        'metadataURI': metadata[4] as String,
      };
    } catch (e) {
      print('❌ Error getting badge metadata: $e');
      return null;
    }
  }

  /// Get total number of minted badges
  Future<int> getTotalSupply() async {
    await initialize();

    try {
      final result = await _client.call(
        contract: _contract,
        function: _totalSupply,
        params: [],
      );

      return (result.first as BigInt).toInt();
    } catch (e) {
      print('❌ Error getting total supply: $e');
      return 0;
    }
  }

  /// Get owner of a specific token
  Future<String?> getTokenOwner(int tokenId) async {
    await initialize();

    try {
      final result = await _client.call(
        contract: _contract,
        function: _ownerOf,
        params: [BigInt.from(tokenId)],
      );

      return (result.first as EthereumAddress).hex;
    } catch (e) {
      print('❌ Error getting token owner: $e');
      return null;
    }
  }

  /// Get token URI (metadata location)
  Future<String?> getTokenURI(int tokenId) async {
    await initialize();

    try {
      final result = await _client.call(
        contract: _contract,
        function: _tokenURI,
        params: [BigInt.from(tokenId)],
      );

      return result.first as String;
    } catch (e) {
      print('❌ Error getting token URI: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.dispose();
  }
}
