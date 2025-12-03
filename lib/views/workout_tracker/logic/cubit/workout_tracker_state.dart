part of 'workout_tracker_cubit.dart';

@immutable
sealed class WorkoutTrackerState {}

/// Trạng thái khởi tạo ban đầu
final class WorkoutTrackerInitial extends WorkoutTrackerState {}

/// Trạng thái khi có thay đổi toggle workout
final class WorkoutToggleChanged extends WorkoutTrackerState {
  final Map<int, bool> toggleStates;
  WorkoutToggleChanged(this.toggleStates);
}

// ============ Các State cho Exercise Categories ============

/// Đang tải danh sách exercise categories
final class ExerciseCategoriesLoading extends WorkoutTrackerState {}

/// Đã tải thành công danh sách exercise categories
final class ExerciseCategoriesLoaded extends WorkoutTrackerState {
  final List<ExerciseCategory> categories;
  ExerciseCategoriesLoaded(this.categories);
}

/// Có lỗi khi tải categories
final class ExerciseCategoriesError extends WorkoutTrackerState {
  final String message;
  ExerciseCategoriesError(this.message);
}

// ============ Các State cho Workout Detail ============

/// Đang tải exercise items cho màn hình detail
final class WorkoutDetailLoading extends WorkoutTrackerState {}

/// Đã tải thành công exercise items
final class WorkoutDetailLoaded extends WorkoutTrackerState {
  final List<ExerciseItem> exercises;

  WorkoutDetailLoaded(this.exercises);

  /// Số lượng exercises
  int get exerciseCount => exercises.length;

  /// Kiểm tra có exercises không
  bool get hasExercises => exercises.isNotEmpty;
}

/// Không có exercises nào
final class WorkoutDetailEmpty extends WorkoutTrackerState {}

/// Có lỗi khi tải detail
final class WorkoutDetailError extends WorkoutTrackerState {
  final String message;
  WorkoutDetailError(this.message);
}

// ============ Các State cho Exercise Session ============

/// Đang trong phiên tập luyện
final class ExerciseSessionActive extends WorkoutTrackerState {
  final List<ExerciseItem> exercises;
  final int currentExerciseIndex;
  final List<WorkoutSet> sets;
  final int elapsedSeconds;
  final bool isExpanded;
  final bool isFinishMode;
  final String categoryId;
  final String categoryName;

  ExerciseSessionActive({
    required this.exercises,
    required this.currentExerciseIndex,
    required this.sets,
    this.elapsedSeconds = 0,
    this.isExpanded = true, // ✅ MẶC ĐỊNH TRUE (mở rộng)
    this.isFinishMode = false,
    required this.categoryId,
    required this.categoryName,
  });

  ExerciseItem get currentExercise => exercises[currentExerciseIndex];
  bool get hasNextExercise => currentExerciseIndex < exercises.length - 1;
  bool get hasPreviousExercise => currentExerciseIndex > 0;
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  /// ✅ Tổng số sets của TẤT CẢ bài tập (mặc định 4 sets/bài)
  int get totalSetsOfAllExercises => exercises.length * 4;

  /// ✅ Tổng số sets đã hoàn thành (bao gồm các bài tập trước + bài hiện tại)
  int get totalCompletedSets {
    // Số bài tập đã hoàn thành trước bài hiện tại
    final completedExercisesBefore = currentExerciseIndex;

    // Mỗi bài đã hoàn thành = 4 sets
    final completedSetsFromPreviousExercises = completedExercisesBefore * 4;

    // Cộng thêm số sets đã hoàn thành của bài hiện tại
    return completedSetsFromPreviousExercises + completedSetsCount;
  }

  /// Kiểm tra xem exercise hiện tại đã hoàn thành tất cả sets chưa
  bool get isCurrentExerciseCompleted => sets.every((s) => s.isCompleted);

  /// Kiểm tra xem đã hoàn thành toàn bộ workout chưa
  bool get isWorkoutCompleted =>
      currentExerciseIndex == exercises.length - 1 &&
      isCurrentExerciseCompleted;

  ExerciseSessionActive copyWith({
    List<ExerciseItem>? exercises,
    int? currentExerciseIndex,
    List<WorkoutSet>? sets,
    int? elapsedSeconds,
    bool? isExpanded,
    bool? isFinishMode,
    String? categoryId,
    String? categoryName,
  }) {
    return ExerciseSessionActive(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      sets: sets ?? this.sets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isExpanded: isExpanded ?? this.isExpanded,
      isFinishMode: isFinishMode ?? this.isFinishMode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
