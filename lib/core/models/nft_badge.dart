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

  factory NFTBadge.fromJson(Map<String, dynamic> json) => NFTBadge(
    id: json['id'],
    tokenId: json['token_id'],
    name: json['name'],
    description: json['description'],
    rarity: BadgeRarity.values.byName(json['rarity']),
    imageUrl: json['image_url'],
    metadata: NFTMetadata.fromJson(json['metadata']),
    mintedAt: DateTime.parse(json['minted_at']),
    ownerAddress: json['owner_address'],
    isShowcased: json['is_showcased'] ?? false,
  );
}

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

  Map<String, dynamic> toJson() => {
    'workout_type': workoutType,
    'total_exercises': totalExercises,
    'duration_minutes': durationMinutes,
    'calories_burned': caloriesBurned,
    'completed_at': completedAt.toIso8601String(),
    'extra_data': extraData,
  };

  factory NFTMetadata.fromJson(Map<String, dynamic> json) => NFTMetadata(
    workoutType: json['workout_type'],
    totalExercises: json['total_exercises'],
    durationMinutes: json['duration_minutes'],
    caloriesBurned: json['calories_burned'],
    completedAt: DateTime.parse(json['completed_at']),
    extraData: json['extra_data'],
  );
}

enum BadgeRarity {
  common, // Workout bình thường
  rare, // 7 day streak
  epic, // 30 day streak
  legendary, // 1000 exercises
}

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

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

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

enum AchievementType {
  totalWorkouts,
  totalExercises,
  streakDays,
  totalCalories,
  specificWorkoutType,
}
