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

/// Trạng thái đang tải danh sách exercise categories
final class ExerciseCategoriesLoading extends WorkoutTrackerState {}

/// Trạng thái đã tải thành công danh sách exercise categories
final class ExerciseCategoriesLoaded extends WorkoutTrackerState {
  final List<ExerciseCategory> categories;
  ExerciseCategoriesLoaded(this.categories);
}

/// Trạng thái có lỗi khi tải dữ liệu
final class ExerciseCategoriesError extends WorkoutTrackerState {
  final String message;
  ExerciseCategoriesError(this.message);
}

/// Trạng thái đang tải exercise items
final class ExerciseItemsLoading extends WorkoutTrackerState {}

/// Trạng thái đã tải thành công exercise items
final class ExerciseItemsLoaded extends WorkoutTrackerState {
  final List<ExerciseItem> exercises;

  /// Lấy danh sách devices unique (không trùng lặp, case-insensitive)
  List<ExerciseItem> get devicesWithEquipment =>
      exercises.where((e) => e.hasEquipment).toList();

  ExerciseItemsLoaded(this.exercises);
}

/// Trạng thái có lỗi khi tải exercise items
final class ExerciseItemsError extends WorkoutTrackerState {
  final String message;
  ExerciseItemsError(this.message);
}
