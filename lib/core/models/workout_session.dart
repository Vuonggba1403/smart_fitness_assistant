class WorkoutSession {
  final String? id;
  final String forUser;
  final String categoryId;
  final String categoryName;
  final int totalExercises;
  final int completedExercises;
  final int totalSets;
  final int completedSets;
  final int durationSeconds;
  final DateTime? createdAt;
  final List<ExerciseSessionDetail> exerciseDetails;

  WorkoutSession({
    this.id,
    required this.forUser,
    required this.categoryId,
    required this.categoryName,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalSets,
    required this.completedSets,
    required this.durationSeconds,
    this.createdAt,
    this.exerciseDetails = const [],
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      forUser: json['for_user'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      totalExercises: json['total_exercises'],
      completedExercises: json['completed_exercises'],
      totalSets: json['total_sets'],
      completedSets: json['completed_sets'],
      durationSeconds: json['duration_seconds'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      exerciseDetails: json['exercise_details'] != null
          ? (json['exercise_details'] as List)
                .map((e) => ExerciseSessionDetail.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_user': forUser,
      'category_id': categoryId,
      'category_name': categoryName,
      'total_exercises': totalExercises,
      'completed_exercises': completedExercises,
      'total_sets': totalSets,
      'completed_sets': completedSets,
      'duration_seconds': durationSeconds,
      'exercise_details': exerciseDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseSessionDetail {
  final String exerciseId;
  final String exerciseName;
  final List<SetDetail> sets;

  ExerciseSessionDetail({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  factory ExerciseSessionDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseSessionDetail(
      exerciseId: json['exercise_id'],
      exerciseName: json['exercise_name'],
      sets: (json['sets'] as List).map((e) => SetDetail.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class SetDetail {
  final int setNumber;
  final double weight;
  final int reps;
  final bool isCompleted;

  SetDetail({
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.isCompleted,
  });

  factory SetDetail.fromJson(Map<String, dynamic> json) {
    return SetDetail(
      setNumber: json['set_number'],
      weight: json['weight'].toDouble(),
      reps: json['reps'],
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'is_completed': isCompleted,
    };
  }
}
