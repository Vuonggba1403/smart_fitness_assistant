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
