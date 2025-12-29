import 'dart:math';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';

class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // Mock wallet address
  String? _walletAddress;

  Future<void> connectWallet() async {
    await Future.delayed(const Duration(seconds: 1));
    _walletAddress = _generateMockAddress();
  }

  Future<NFTBadge> mintBadge({
    required String name,
    required String description,
    required BadgeRarity rarity,
    required NFTMetadata metadata,
  }) async {
    if (_walletAddress == null) {
      await connectWallet();
    }

    // Simulate blockchain transaction
    await Future.delayed(const Duration(seconds: 2));

    final tokenId = _generateTokenId();
    final badge = NFTBadge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenId: tokenId,
      name: name,
      description: description,
      rarity: rarity,
      imageUrl: _getBadgeImageUrl(rarity, metadata.workoutType),
      metadata: metadata,
      mintedAt: DateTime.now(),
      ownerAddress: _walletAddress!,
    );

    return badge;
  }

  Future<List<NFTBadge>> getUserBadges(String userId) async {
    // Mock: Lấy từ Supabase hoặc blockchain
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  String _generateMockAddress() {
    final random = Random();
    return '0x${List.generate(40, (_) => random.nextInt(16).toRadixString(16)).join()}';
  }

  String _generateTokenId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _getBadgeImageUrl(BadgeRarity rarity, String workoutType) {
    // Mock URLs - thay bằng IPFS hoặc CDN thực tế
    final rarityPrefix = rarity.name;
    return 'https://your-nft-storage.com/badges/$rarityPrefix-$workoutType.png';
  }

  String? get walletAddress => _walletAddress;
}
