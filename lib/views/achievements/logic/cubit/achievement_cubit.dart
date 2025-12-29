import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/services/blockchain_service.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_state.dart';

class AchievementCubit extends Cubit<AchievementState> {
  final BlockchainService _blockchainService = BlockchainService();

  AchievementCubit() : super(AchievementState.initial()) {
    _initializeAchievements();
  }

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

  Future<NFTBadge?> mintWorkoutBadge({
    required String workoutType,
    required int totalExercises,
    required int durationMinutes,
    required double caloriesBurned,
  }) async {
    emit(state.copyWith(isMinting: true));

    try {
      final metadata = NFTMetadata(
        workoutType: workoutType,
        totalExercises: totalExercises,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        completedAt: DateTime.now(),
      );

      // Xác định rarity dựa trên achievement
      final rarity = _determineRarity(totalExercises, durationMinutes);

      final badge = await _blockchainService.mintBadge(
        name: '$workoutType Completed',
        description:
            'Completed $workoutType workout with $totalExercises exercises',
        rarity: rarity,
        metadata: metadata,
      );

      final updatedBadges = [...state.badges, badge];
      emit(
        state.copyWith(
          badges: updatedBadges,
          isMinting: false,
          lastMintedBadge: badge,
        ),
      );

      // Update achievements
      _updateAchievements(totalExercises);

      return badge;
    } catch (e) {
      emit(state.copyWith(isMinting: false, error: e.toString()));
      return null;
    }
  }

  BadgeRarity _determineRarity(int exercises, int duration) {
    // Logic xác định độ hiếm
    if (exercises >= 20 && duration >= 60) return BadgeRarity.legendary;
    if (exercises >= 15 && duration >= 45) return BadgeRarity.epic;
    if (exercises >= 10 && duration >= 30) return BadgeRarity.rare;
    return BadgeRarity.common;
  }

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

  void toggleShowcase(String badgeId) {
    final updatedBadges = state.badges.map((badge) {
      if (badge.id == badgeId) {
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
          isShowcased: !badge.isShowcased,
        );
      }
      return badge;
    }).toList();

    emit(state.copyWith(badges: updatedBadges));
  }
}
