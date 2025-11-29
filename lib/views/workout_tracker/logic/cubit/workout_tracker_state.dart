part of 'workout_tracker_cubit.dart';

@immutable
sealed class WorkoutTrackerState {}

/// Trạng thái khởi tạo ban đầu
final class WorkoutTrackerInitial extends WorkoutTrackerState {}

/// Trạng thái khi có thay đổi toggle workout
/// [toggleStates] - Map chứa trạng thái toggle của các workout
final class WorkoutToggleChanged extends WorkoutTrackerState {
  final Map<int, bool> toggleStates;
  WorkoutToggleChanged(this.toggleStates);
}

/// Trạng thái đang tải danh sách exercise categories
final class ExerciseCategoriesLoading extends WorkoutTrackerState {}

/// Trạng thái đã tải thành công danh sách exercise categories
/// [categories] - Danh sách các category từ Supabase
final class ExerciseCategoriesLoaded extends WorkoutTrackerState {
  final List<Map<String, dynamic>> categories;
  ExerciseCategoriesLoaded(this.categories);
}

/// Trạng thái có lỗi khi tải dữ liệu
/// [message] - Thông báo lỗi chi tiết
final class ExerciseCategoriesError extends WorkoutTrackerState {
  final String message;
  ExerciseCategoriesError(this.message);
}
