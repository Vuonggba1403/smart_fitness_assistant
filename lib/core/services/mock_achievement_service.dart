import 'dart:math';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock Achievement Service - Simulates NFT badge system for demo purposes
///
/// Provides a complete badge management system without blockchain complexity.
/// All data is stored locally in Supabase for persistence across sessions.
///
/// Features:
/// - Mock badge minting with realistic delays
/// - Local database persistence
/// - Badge showcase management
/// - Zero external dependencies
///
/// Note: This is a DEMO service. No real blockchain integration.
class MockAchievementService {
  // Singleton pattern for global access
  static final MockAchievementService _instance =
      MockAchievementService._internal();
  factory MockAchievementService() => _instance;
  MockAchievementService._internal();

  // Dependencies
  final _supabase = Supabase.instance.client;
  final _random = Random();

  // Constants
  static const String _mockWalletAddress = '0xDemo1234567890abcdef';
  static const int _mintDelayMs = 800;
  static const int _tokenRandomRange = 9999;
  static const String _badgeTable = 'nft_badges';

  /// Initializes the mock achievement service
  Future<void> initialize() async {
    print('✅ Mock Achievement Service initialized');
  }

  /// Creates and persists a new achievement badge
  Future<NFTBadge> mintBadge({
    required String name,
    required String description,
    required BadgeRarity rarity,
    required NFTMetadata metadata,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: _mintDelayMs));

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
      ownerAddress: _mockWalletAddress,
      isShowcased: false,
    );

    if (userId != null) {
      await _saveBadgeToDatabase(badge, userId);
    }

    print('✅ Mock badge minted: ${badge.name} (${badge.rarity.name})');
    return badge;
  }

  /// Retrieves all badges for a specific user sorted by mint date
  Future<List<NFTBadge>> getUserBadges(String userId) async {
    try {
      final response = await _supabase
          .from(_badgeTable)
          .select()
          .eq('user_id', userId)
          .order('minted_at', ascending: false);

      return response.map((json) => NFTBadge.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ Error loading badges: $e');
      return [];
    }
  }

  /// Updates the showcase status of a badge
  Future<void> toggleShowcase(String badgeId, bool isShowcased) async {
    try {
      await _supabase
          .from(_badgeTable)
          .update({'is_showcased': isShowcased})
          .eq('id', badgeId);
    } catch (e) {
      print('⚠️ Error toggling showcase: $e');
    }
  }

  /// Deletes a badge from local storage (demo-only feature)
  Future<void> deleteBadge(String badgeId) async {
    try {
      await _supabase.from(_badgeTable).delete().eq('id', badgeId);
      print('✅ Badge deleted: $badgeId');
    } catch (e) {
      print('⚠️ Error deleting badge: $e');
    }
  }

  // ============================================================
  // PRIVATE HELPER METHODS
  // ============================================================

  /// Generates a unique token ID using timestamp and random number
  String _generateTokenId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(_tokenRandomRange);
    return '$timestamp$randomSuffix';
  }

  /// Returns the badge image path based on rarity and workout type
  String _getBadgeImageUrl(BadgeRarity rarity, String workoutType) {
    const workoutImageMap = {
      'cardio': 'running',
      'strength': 'dumbbell',
      'flexibility': 'yoga',
      'hiit': 'fire',
      'endurance': 'mountain',
      'balance': 'zen',
    };

    final imageType = workoutImageMap[workoutType.toLowerCase()] ?? 'trophy';
    final rarityPrefix = rarity.name.toLowerCase();

    return 'assets/img/badges/${rarityPrefix}_$imageType.png';
  }

  /// Persists badge data to Supabase database
  Future<void> _saveBadgeToDatabase(NFTBadge badge, String userId) async {
    try {
      await _supabase.from(_badgeTable).insert({
        'id': badge.id,
        'user_id': userId,
        'token_id': badge.tokenId,
        'name': badge.name,
        'description': badge.description,
        'rarity': badge.rarity.name,
        'image_url': badge.imageUrl,
        'metadata': badge.metadata.toJson(),
        'minted_at': badge.mintedAt.toIso8601String(),
        'owner_address': badge.ownerAddress,
        'is_showcased': badge.isShowcased,
      });
      print('💾 Badge saved to database');
    } catch (e) {
      print('⚠️ Error saving badge: $e');
    }
  }
}
