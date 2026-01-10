import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/services/mock_achievement_service.dart';
import 'package:smart_fitness_assistant/core/services/blockchain_service.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages achievement tracking and badge minting for workout milestones
///
/// Supports TWO MODES:
/// 1. MOCK MODE (default): Fast, free, uses Supabase database
/// 2. BLOCKCHAIN MODE: Real NFTs on Polygon (requires wallet & testnet MATIC)
///
/// To enable blockchain: Set useBlockchain = true
/// Handles:
/// - Badge creation after workout completion
/// - Achievement progress tracking
/// - Badge showcase management
/// - User badge collection
class AchievementCubit extends Cubit<AchievementState> {
  // Services
  final MockAchievementService _mockService = MockAchievementService();
  final BlockchainService _blockchainService = BlockchainService();
  final _supabase = Supabase.instance.client;

  // 🔧 CONFIG: Toggle blockchain mode
  // Set to true to mint real NFTs on Polygon blockchain
  // Set to false to use mock service (faster, no cost)
  static const bool useBlockchain = true; // ✅ ENABLED for testing

  // 🔐 BLOCKCHAIN CONFIG (only needed if useBlockchain = true)
  // ⚠️ SECURITY: In production, fetch from secure backend
  // For testnet demo, you can hardcode here
  static const String ownerPrivateKey =
      '79058a6b72e672efad15bd16d6706a3d0c81b08d313b479f62f2566dd1283f6d'; // Your private key
  static const String userWalletAddress =
      '0xbf415e204220c66732243c1B5DBfB45310dcC3bc'; // Your wallet address

  // Badge rarity thresholds
  static const int _legendaryExercises = 20;
  static const int _legendaryDuration = 60;
  static const int _epicExercises = 15;
  static const int _epicDuration = 45;
  static const int _rareExercises = 10;
  static const int _rareDuration = 30;

  AchievementCubit() : super(AchievementState.initial()) {
    _initialize();
  }

  /// Initializes service and pre-defined achievements
  Future<void> _initialize() async {
    await _initializeService();
    _initializeAchievements();
  }

  /// Initializes the achievement service (Mock or Blockchain)
  Future<void> _initializeService() async {
    try {
      if (useBlockchain) {
        await _blockchainService.initialize();
        print('✅ Blockchain Service initialized (Real NFT mode)');
        print('🌐 Network: Polygon Amoy Testnet');
        print('📝 Contract: 0x365d5d61596E2d1FaA9111c20C428009c69748cd');
      } else {
        await _mockService.initialize();
        print('✅ Mock Achievement Service initialized (Demo mode)');
        print('💾 Storage: Supabase database');
      }
    } catch (e) {
      print('❌ Failed to initialize service: $e');
    }
  }

  /// Loads all badges for the current authenticated user
  Future<void> loadUserBadges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Always load from database (both modes save there)
      final badges = await _mockService.getUserBadges(userId);
      emit(state.copyWith(badges: badges));
      print('✅ Loaded ${badges.length} badges');

      if (useBlockchain) {
        print('🔗 Blockchain mode: Badges are also on-chain');
      }
    } catch (e) {
      print('❌ Error loading badges: $e');
    }
  }

  /// Initializes pre-defined achievement milestones
  void _initializeAchievements() {
    final achievements = [
      Achievement(
        id: '1',
        name: 'First Workout',
        description: 'Complete your first workout',
        type: AchievementType.totalWorkouts,
        targetValue: 1,
        currentValue: 0,
        badgeRarity: BadgeRarity.common,
        badgeImageUrl: '',
      ),
      Achievement(
        id: '2',
        name: 'Week Warrior',
        description: '7 day workout streak',
        type: AchievementType.streakDays,
        targetValue: 7,
        currentValue: 0,
        badgeRarity: BadgeRarity.rare,
        badgeImageUrl: '',
      ),
      Achievement(
        id: '3',
        name: 'Month Master',
        description: '30 day workout streak',
        type: AchievementType.streakDays,
        targetValue: 30,
        currentValue: 0,
        badgeRarity: BadgeRarity.epic,
        badgeImageUrl: '',
      ),
      Achievement(
        id: '4',
        name: 'Exercise Legend',
        description: 'Complete 1000 exercises',
        type: AchievementType.totalExercises,
        targetValue: 1000,
        currentValue: 0,
        badgeRarity: BadgeRarity.legendary,
        badgeImageUrl: '',
      ),
    ];

    emit(state.copyWith(achievements: achievements));
  }

  /// Creates a new badge for completed workout and updates achievements
  ///
  /// HYBRID MODE:
  /// - Always saves to database (fast, reliable)
  /// - If useBlockchain=true: Also mints real NFT on Polygon
  Future<NFTBadge?> mintWorkoutBadge({
    required String workoutType,
    required int totalExercises,
    required int durationMinutes,
    required double caloriesBurned,
  }) async {
    emit(state.copyWith(isMinting: true));

    try {
      final userId = _supabase.auth.currentUser?.id;

      final metadata = NFTMetadata(
        workoutType: workoutType,
        totalExercises: totalExercises,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        completedAt: DateTime.now(),
      );

      final rarity = _determineRarity(totalExercises, durationMinutes);

      // 1. ALWAYS save to database (mock service)
      final badge = await _mockService.mintBadge(
        name: '$workoutType Completed',
        description:
            'Completed $workoutType workout with $totalExercises exercises',
        rarity: rarity,
        metadata: metadata,
        userId: userId,
      );

      // 2. OPTIONAL: Mint real NFT on blockchain
      if (useBlockchain) {
        try {
          print('🔗 Minting NFT on Polygon blockchain...');
          final tokenId = await _blockchainService.mintWorkoutBadge(
            userAddress: userWalletAddress,
            workoutCount: totalExercises,
            privateKey: ownerPrivateKey,
          );
          print('✅ NFT minted on-chain! Token ID: $tokenId');
          print(
            '🔍 View on PolygonScan: https://amoy.polygonscan.com/token/0x365d5d61596E2d1FaA9111c20C428009c69748cd?a=$tokenId',
          );
        } catch (blockchainError) {
          print(
            '⚠️ Blockchain mint failed (badge still saved in database): $blockchainError',
          );
          // Don't fail the whole operation if blockchain fails
        }
      }

      final updatedBadges = [...state.badges, badge];
      emit(
        state.copyWith(
          badges: updatedBadges,
          isMinting: false,
          lastMintedBadge: badge,
        ),
      );

      _updateAchievements(totalExercises);

      return badge;
    } catch (e) {
      emit(state.copyWith(isMinting: false, error: e.toString()));
      return null;
    }
  }

  /// Determines badge rarity based on workout metrics
  BadgeRarity _determineRarity(int exercises, int duration) {
    if (exercises >= _legendaryExercises && duration >= _legendaryDuration) {
      return BadgeRarity.legendary;
    }
    if (exercises >= _epicExercises && duration >= _epicDuration) {
      return BadgeRarity.epic;
    }
    if (exercises >= _rareExercises && duration >= _rareDuration) {
      return BadgeRarity.rare;
    }
    return BadgeRarity.common;
  }

  /// Updates achievement progress after workout completion
  void _updateAchievements(int exercisesCompleted) {
    final updatedAchievements = state.achievements.map((achievement) {
      if (achievement.type == AchievementType.totalWorkouts) {
        final newValue = achievement.currentValue + 1;
        return achievement.copyWith(
          currentValue: newValue,
          isCompleted: newValue >= achievement.targetValue,
          completedAt: newValue >= achievement.targetValue
              ? DateTime.now()
              : null,
        );
      }
      if (achievement.type == AchievementType.totalExercises) {
        final newValue = achievement.currentValue + exercisesCompleted;
        return achievement.copyWith(
          currentValue: newValue,
          isCompleted: newValue >= achievement.targetValue,
          completedAt: newValue >= achievement.targetValue
              ? DateTime.now()
              : null,
        );
      }
      return achievement;
    }).toList();

    emit(state.copyWith(achievements: updatedAchievements));
  }

  /// Updates streak-based achievements with current streak count
  void updateStreakDays(int streakDays) {
    final updatedAchievements = state.achievements.map((achievement) {
      if (achievement.type == AchievementType.streakDays) {
        return achievement.copyWith(
          currentValue: streakDays,
          isCompleted: streakDays >= achievement.targetValue,
          completedAt: streakDays >= achievement.targetValue
              ? DateTime.now()
              : null,
        );
      }
      return achievement;
    }).toList();

    emit(state.copyWith(achievements: updatedAchievements));
  }

  /// Toggles the showcase status of a badge
  void toggleShowcase(String badgeId) {
    final updatedBadges = state.badges.map((badge) {
      if (badge.id == badgeId) {
        final newIsShowcased = !badge.isShowcased;
        _mockService.toggleShowcase(badgeId, newIsShowcased);
        return _createUpdatedBadge(badge, newIsShowcased);
      }
      return badge;
    }).toList();

    emit(state.copyWith(badges: updatedBadges));
  }

  /// Creates a copy of badge with updated showcase status
  NFTBadge _createUpdatedBadge(NFTBadge badge, bool isShowcased) {
    return NFTBadge(
      id: badge.id,
      tokenId: badge.tokenId,
      name: badge.name,
      description: badge.description,
      rarity: badge.rarity,
      imageUrl: badge.imageUrl,
      metadata: badge.metadata,
      mintedAt: badge.mintedAt,
      ownerAddress: badge.ownerAddress,
      isShowcased: isShowcased,
    );
  }
}
