class WorkoutProgress {
  final String? id;
  final String forUser;
  final String categoryId;
  final String exerciseId;
  final int completedSets;
  final int totalSets;
  final bool isFullyCompleted;
  final DateTime? lastUpdated;

  WorkoutProgress({
    this.id,
    required this.forUser,
    required this.categoryId,
    required this.exerciseId,
    required this.completedSets,
    this.totalSets = 4,
    this.isFullyCompleted = false,
    this.lastUpdated,
  });

  factory WorkoutProgress.fromJson(Map<String, dynamic> json) {
    return WorkoutProgress(
      id: json['id'],
      forUser: json['for_user'],
      categoryId: json['for_category'],
      exerciseId: json['for_exercise'],
      completedSets: json['completed_sets'] ?? 0,
      totalSets: json['total_sets'] ?? 4,
      isFullyCompleted: json['is_completed'] ?? false,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_user': forUser,
      'for_category': categoryId,
      'for_exercise': exerciseId,
      'completed_sets': completedSets,
      'total_sets': totalSets,
      'is_completed': isFullyCompleted,
    };
  }

  double get progressPercent => completedSets / totalSets;
}
