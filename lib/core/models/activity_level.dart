class ActivityLevel {
  final String id; // ✅ UUID string từ Supabase
  final String title;
  final double activityFactor;
  final String description;
  final String? workoutsPer; // workouts_per_week
  final int number; // int2
  final String? icon;
  final DateTime createdAt;

  ActivityLevel({
    required this.id,
    required this.title,
    required this.activityFactor,
    required this.description,
    this.workoutsPer,
    required this.number,
    this.icon,
    required this.createdAt,
  });

  /// Convert từ JSON (Supabase) sang Model
  factory ActivityLevel.fromJson(Map<String, dynamic> json) {
    return ActivityLevel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      activityFactor: (json['activity_factor'] as num?)?.toDouble() ?? 1.2,
      description: json['description'] as String? ?? '',
      workoutsPer: json['workouts_per'] as String?,
      number: json['number'] as int? ?? 0,
      icon: json['icon'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'activity_factor': activityFactor,
    'description': description,
    'workouts_per': workoutsPer,
    'number': number,
    'icon': icon,
    'created_at': createdAt.toIso8601String(),
  };
}
