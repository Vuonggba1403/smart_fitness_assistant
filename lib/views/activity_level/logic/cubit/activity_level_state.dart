part of 'activity_level_cubit.dart';

@immutable
sealed class ActivityLevelState {}

/// 🔵 State khởi tạo
final class ActivityLevelInitial extends ActivityLevelState {}

/// ⏳ State đang load
final class ActivityLevelLoading extends ActivityLevelState {}

/// ✅ State load thành công danh sách activity levels
final class ActivityLevelsLoaded extends ActivityLevelState {
  final List<ActivityLevel> activityLevels;
  ActivityLevelsLoaded(this.activityLevels);
}

/// 💾 State lưu preference thành công
final class ActivityPreferenceSaved extends ActivityLevelState {
  final String activityId;
  final int dailyCalories;
  ActivityPreferenceSaved(this.activityId, this.dailyCalories);
}

/// ❌ State lỗi
final class ActivityLevelError extends ActivityLevelState {
  final String message;
  ActivityLevelError(this.message);
}
