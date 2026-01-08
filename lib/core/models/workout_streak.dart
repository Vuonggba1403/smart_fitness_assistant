// lib/core/models/workout_streak.dart
class WorkoutStreak {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final DateTime? streakStartDate;
  final int totalWorkouts;
  final bool blockchainSynced;
  final String? lastBlockchainTxHash;

  WorkoutStreak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    this.streakStartDate,
    required this.totalWorkouts,
    this.blockchainSynced = false,
    this.lastBlockchainTxHash,
  });

  factory WorkoutStreak.fromJson(Map<String, dynamic> json) {
    return WorkoutStreak(
      id: json['id'],
      userId: json['for_user'],
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'])
          : null,
      streakStartDate: json['streak_start_date'] != null
          ? DateTime.parse(json['streak_start_date'])
          : null,
      totalWorkouts: json['total_workouts'] ?? 0,
      blockchainSynced: json['blockchain_synced'] ?? false,
      lastBlockchainTxHash: json['last_blockchain_tx_hash'],
    );
  }
}

class StreakMilestone {
  final String id;
  final String userId;
  final int milestoneDays;
  final DateTime achievedAt;
  final String? nftTokenId;
  final String? nftContractAddress;
  final String? blockchainTxHash;
  final String? nftMetadataUri;

  StreakMilestone({
    required this.id,
    required this.userId,
    required this.milestoneDays,
    required this.achievedAt,
    this.nftTokenId,
    this.nftContractAddress,
    this.blockchainTxHash,
    this.nftMetadataUri,
  });
}
