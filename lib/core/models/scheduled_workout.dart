class ScheduledWorkout {
  final String? id;
  final String forUser;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final DateTime scheduledTime;
  final bool hasNotification;
  final bool isCompleted;
  final DateTime? createdAt;

  ScheduledWorkout({
    this.id,
    required this.forUser,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.scheduledTime,
    this.hasNotification = false,
    this.isCompleted = false,
    this.createdAt,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      id: json['id'],
      forUser: json['for_user'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      imageUrl: json['image_url'] ?? '',
      scheduledTime: DateTime.parse(json['scheduled_time']),
      hasNotification: json['has_notification'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_user': forUser,
      'category_id': categoryId,
      'category_name': categoryName,
      'image_url': imageUrl,
      'scheduled_time': scheduledTime.toIso8601String(),
      'has_notification': hasNotification,
      'is_completed': isCompleted,
    };
  }

  ScheduledWorkout copyWith({
    String? id,
    String? forUser,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    DateTime? scheduledTime,
    bool? hasNotification,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ScheduledWorkout(
      id: id ?? this.id,
      forUser: forUser ?? this.forUser,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      hasNotification: hasNotification ?? this.hasNotification,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
