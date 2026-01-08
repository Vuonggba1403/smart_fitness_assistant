/// Represents an achievement badge earned from workout completion
///
/// Badges are stored locally and include workout metadata.
/// This is a demo model designed to simulate NFT-style achievements.

import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

class NFTBadge {
  final String id;
  final String tokenId;
  final String name;
  final String description;
  final BadgeRarity rarity;
  final String imageUrl;
  final NFTMetadata metadata;
  final DateTime mintedAt;
  final String ownerAddress;
  final bool isShowcased;

  NFTBadge({
    required this.id,
    required this.tokenId,
    required this.name,
    required this.description,
    required this.rarity,
    required this.imageUrl,
    required this.metadata,
    required this.mintedAt,
    required this.ownerAddress,
    this.isShowcased = false,
  });

  /// Converts badge to JSON for database storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'token_id': tokenId,
    'name': name,
    'description': description,
    'rarity': rarity.name,
    'image_url': imageUrl,
    'metadata': metadata.toJson(),
    'minted_at': mintedAt.toIso8601String(),
    'owner_address': ownerAddress,
    'is_showcased': isShowcased,
  };

  /// Creates badge from JSON data (from database)
  factory NFTBadge.fromJson(Map<String, dynamic> json) {
    // Parse rarity - handle both lowercase and capitalized
    final rarityStr = (json['rarity'] as String).toLowerCase();
    final rarity = BadgeRarity.values.firstWhere(
      (e) => e.name.toLowerCase() == rarityStr,
      orElse: () => BadgeRarity.common,
    );

    // Parse metadata - handle both Map and already parsed object
    final metadataJson = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};

    return NFTBadge(
      id: json['id'] ?? '',
      tokenId: json['token_id']?.toString() ?? '0',
      name: json['name'] ?? 'Unknown Badge',
      description: json['description'] ?? '',
      rarity: rarity,
      imageUrl: json['image_url'] ?? '',
      metadata: NFTMetadata.fromJson(metadataJson),
      mintedAt: DateTime.parse(json['minted_at']),
      ownerAddress: json['owner_address'] ?? '',
      isShowcased: json['is_showcased'] ?? false,
    );
  }
}

/// Contains detailed workout metrics for a badge
///
/// Stores the workout session data that earned the badge.
class NFTMetadata {
  final String workoutType;
  final int totalExercises;
  final int durationMinutes;
  final double caloriesBurned;
  final DateTime completedAt;
  final Map<String, dynamic>? extraData;

  NFTMetadata({
    required this.workoutType,
    required this.totalExercises,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.completedAt,
    this.extraData,
  });

  /// Converts metadata to JSON for storage
  Map<String, dynamic> toJson() => {
    'workout_type': workoutType,
    'total_exercises': totalExercises,
    'duration_minutes': durationMinutes,
    'calories_burned': caloriesBurned,
    'completed_at': completedAt.toIso8601String(),
    'extra_data': extraData,
  };

  /// Creates metadata from JSON data
  factory NFTMetadata.fromJson(Map<String, dynamic> json) {
    return NFTMetadata(
      workoutType: json['workout_type'] ?? 'Unknown',
      totalExercises: json['total_exercises'] ?? 0,
      durationMinutes: json['duration_minutes'] ?? 0,
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
      extraData: json['extra_data'] as Map<String, dynamic>?,
    );
  }
}

/// Badge rarity levels based on workout difficulty
enum BadgeRarity {
  common, // Basic workout completion
  rare, // Challenging workout (10+ exercises, 30+ minutes)
  epic, // Intense workout (15+ exercises, 45+ minutes)
  legendary, // Elite workout (20+ exercises, 60+ minutes)
}

/// ✅ Extension để locale rarity
extension BadgeRarityExtension on BadgeRarity {
  String get localized {
    switch (this) {
      case BadgeRarity.common:
        return LocaleKey.common.tr;
      case BadgeRarity.rare:
        return LocaleKey.rare.tr;
      case BadgeRarity.epic:
        return LocaleKey.epic.tr;
      case BadgeRarity.legendary:
        return LocaleKey.legendary.tr;
    }
  }
}

/// Represents a milestone achievement that can be earned
///
/// Tracks progress towards specific fitness goals.
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final int targetValue;
  final int currentValue;
  final BadgeRarity badgeRarity;
  final String badgeImageUrl;
  final bool isCompleted;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.badgeRarity,
    required this.badgeImageUrl,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Calculates completion progress as percentage (0.0 to 1.0)
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  /// Creates a copy with updated values
  Achievement copyWith({
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
  }) => Achievement(
    id: id,
    name: name,
    description: description,
    type: type,
    targetValue: targetValue,
    currentValue: currentValue ?? this.currentValue,
    badgeRarity: badgeRarity,
    badgeImageUrl: badgeImageUrl,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt ?? this.completedAt,
  );
}

/// Types of achievements that can be tracked
enum AchievementType {
  totalWorkouts, // Total number of workout sessions
  totalExercises, // Total number of exercises completed
  streakDays, // Consecutive days with workouts
  totalCalories, // Total calories burned
  specificWorkoutType, // Specific workout category completion
}
