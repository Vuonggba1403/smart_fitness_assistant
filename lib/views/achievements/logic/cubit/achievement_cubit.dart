import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/services/mock_achievement_service.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages achievement tracking and badge minting for workout milestones
///
/// Handles:
/// - Badge creation after workout completion
/// - Achievement progress tracking
/// - Badge showcase management
/// - User badge collection
class AchievementCubit extends Cubit<AchievementState> {
  final MockAchievementService _achievementService = MockAchievementService();
  final _supabase = Supabase.instance.client;

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

  /// Initializes the mock achievement service
  Future<void> _initializeService() async {
    try {
      await _achievementService.initialize();
      print('✅ Mock Achievement Service initialized');
    } catch (e) {
      print('❌ Failed to initialize service: $e');
    }
  }

  /// Loads all badges for the current authenticated user
  Future<void> loadUserBadges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final badges = await _achievementService.getUserBadges(userId);
      emit(state.copyWith(badges: badges));
      print('✅ Loaded ${badges.length} badges');
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

      final badge = await _achievementService.mintBadge(
        name: '$workoutType Completed',
        description:
            'Completed $workoutType workout with $totalExercises exercises',
        rarity: rarity,
        metadata: metadata,
        userId: userId,
      );

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
        _achievementService.toggleShowcase(badgeId, newIsShowcased);
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
