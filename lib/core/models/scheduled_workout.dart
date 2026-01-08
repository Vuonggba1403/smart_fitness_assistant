import 'package:smart_fitness_assistant/core/models/exercise_category.dart';

class ScheduledWorkout {
  final String? id;
  final String forUser;
  final String categoryId;
  final DateTime scheduledTime;
  final bool hasNotification;
  final bool isCompleted;
  final DateTime? createdAt;

  // ✅ Joined data from exercise_categories
  final String? categoryName;
  final String? categoryImage;

  ScheduledWorkout({
    this.id,
    required this.forUser,
    required this.categoryId,
    required this.scheduledTime,
    this.hasNotification = false,
    this.isCompleted = false,
    this.createdAt,
    this.categoryName,
    this.categoryImage,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    // ✅ Parse joined exercise_categories data
    String? categoryName;
    String? categoryImage;

    if (json['exercise_categories'] != null) {
      final category = json['exercise_categories'] as Map<String, dynamic>;
      final exerciseCategory = ExerciseCategory.fromJson(category);
      categoryName = exerciseCategory.localizedTitleEx;
      categoryImage = category['img_url'];
    }

    return ScheduledWorkout(
      id: json['id'],
      forUser: json['for_user'],
      categoryId: json['category_id'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      hasNotification: json['has_notification'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      categoryName: categoryName,
      categoryImage: categoryImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_user': forUser,
      'category_id': categoryId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'has_notification': hasNotification,
      'is_completed': isCompleted,
    };
  }

  ScheduledWorkout copyWith({
    String? id,
    String? forUser,
    String? categoryId,
    DateTime? scheduledTime,
    bool? hasNotification,
    bool? isCompleted,
    DateTime? createdAt,
    String? categoryName,
    String? categoryImage,
  }) {
    return ScheduledWorkout(
      id: id ?? this.id,
      forUser: forUser ?? this.forUser,
      categoryId: categoryId ?? this.categoryId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      hasNotification: hasNotification ?? this.hasNotification,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      categoryImage: categoryImage ?? this.categoryImage,
    );
  }
}
