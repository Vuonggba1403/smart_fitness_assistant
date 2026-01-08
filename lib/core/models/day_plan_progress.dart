/// Model để track tiến độ hoàn thành của từng ngày trong workout plan
class DayPlanProgress {
  final int dayNumber;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? workoutDurationSeconds; // Thời gian tập thực tế
  final int totalExercises; // Tổng số bài tập trong ngày
  final int completedExercises; // Số bài tập đã hoàn thành

  DayPlanProgress({
    required this.dayNumber,
    this.isCompleted = false,
    this.completedAt,
    this.workoutDurationSeconds,
    this.totalExercises = 0,
    this.completedExercises = 0,
  });

  factory DayPlanProgress.fromJson(Map<String, dynamic> json) {
    return DayPlanProgress(
      dayNumber: json['day_number'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      workoutDurationSeconds: json['workout_duration_seconds'] as int?,
      totalExercises: json['total_exercises'] as int? ?? 0,
      completedExercises: json['completed_exercises'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'workout_duration_seconds': workoutDurationSeconds,
      'total_exercises': totalExercises,
      'completed_exercises': completedExercises,
    };
  }

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalExercises == 0) return 0.0;
    return completedExercises / totalExercises;
  }

  /// Copy với modifications
  DayPlanProgress copyWith({
    int? dayNumber,
    bool? isCompleted,
    DateTime? completedAt,
    int? workoutDurationSeconds,
    int? totalExercises,
    int? completedExercises,
  }) {
    return DayPlanProgress(
      dayNumber: dayNumber ?? this.dayNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      workoutDurationSeconds:
          workoutDurationSeconds ?? this.workoutDurationSeconds,
      totalExercises: totalExercises ?? this.totalExercises,
      completedExercises: completedExercises ?? this.completedExercises,
    );
  }

  /// Tạo progress mới cho ngày mới
  factory DayPlanProgress.initial(int dayNumber, int totalExercises) {
    return DayPlanProgress(
      dayNumber: dayNumber,
      totalExercises: totalExercises,
      completedExercises: 0,
    );
  }
}

/// Model để lưu toàn bộ progress của workout plan
class WorkoutPlanProgress {
  final String planId;
  final String userId;
  final List<DayPlanProgress> dayProgressList;
  final DateTime startedAt;
  final DateTime? completedAt;

  WorkoutPlanProgress({
    required this.planId,
    required this.userId,
    required this.dayProgressList,
    required this.startedAt,
    this.completedAt,
  });

  factory WorkoutPlanProgress.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanProgress(
      planId: json['plan_id'] as String,
      userId: json['user_id'] as String,
      dayProgressList: (json['day_progress_list'] as List)
          .map((e) => DayPlanProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'user_id': userId,
      'day_progress_list': dayProgressList.map((e) => e.toJson()).toList(),
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Số ngày đã hoàn thành
  int get completedDaysCount {
    return dayProgressList.where((d) => d.isCompleted).length;
  }

  /// Plan progress percentage (0.0 to 1.0)
  double get overallProgress {
    if (dayProgressList.isEmpty) return 0.0;
    return completedDaysCount / dayProgressList.length;
  }

  /// Kiểm tra xem plan đã hoàn thành chưa (7/7 ngày)
  bool get isPlanCompleted {
    return dayProgressList.every((day) => day.isCompleted);
  }

  /// Get progress của ngày cụ thể
  DayPlanProgress? getProgressForDay(int dayNumber) {
    try {
      return dayProgressList.firstWhere((d) => d.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }

  /// Update progress cho 1 ngày
  WorkoutPlanProgress updateDayProgress(DayPlanProgress updatedDay) {
    final updatedList = dayProgressList.map((day) {
      return day.dayNumber == updatedDay.dayNumber ? updatedDay : day;
    }).toList();

    return WorkoutPlanProgress(
      planId: planId,
      userId: userId,
      dayProgressList: updatedList,
      startedAt: startedAt,
      completedAt: isPlanCompleted ? DateTime.now() : completedAt,
    );
  }

  /// Tạo progress mới cho plan mới
  factory WorkoutPlanProgress.initial({
    required String planId,
    required String userId,
    required int totalDays,
    required Map<int, int> dayExerciseCounts, // Map<dayNumber, exerciseCount>
  }) {
    final dayProgressList = List.generate(totalDays, (index) {
      final dayNumber = index + 1;
      final exerciseCount = dayExerciseCounts[dayNumber] ?? 0;
      return DayPlanProgress.initial(dayNumber, exerciseCount);
    });

    return WorkoutPlanProgress(
      planId: planId,
      userId: userId,
      dayProgressList: dayProgressList,
      startedAt: DateTime.now(),
    );
  }
}
