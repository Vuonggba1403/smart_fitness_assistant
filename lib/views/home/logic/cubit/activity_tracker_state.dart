part of 'activity_tracker_cubit.dart';

@immutable
sealed class ActivityTrackerState {}

final class ActivityTrackerInitial extends ActivityTrackerState {}

final class ActivityTrackerLoading extends ActivityTrackerState {}

final class ActivityTrackerLoaded extends ActivityTrackerState {
  final int totalWaterMl;
  final int waterGoalMl;
  final List<WaterIntake> waterIntakes;

  ActivityTrackerLoaded({
    required this.totalWaterMl,
    required this.waterGoalMl,
    required this.waterIntakes,
  });

  double get waterProgress =>
      waterGoalMl > 0 ? (totalWaterMl / waterGoalMl).clamp(0.0, 1.0) : 0.0;
}

final class ActivityTrackerError extends ActivityTrackerState {
  final String message;
  ActivityTrackerError(this.message);
}
