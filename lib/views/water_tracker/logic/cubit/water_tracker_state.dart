part of 'water_tracker_cubit.dart';

@immutable
sealed class WaterTrackerState {}

final class WaterTrackerInitial extends WaterTrackerState {}

final class WaterTrackerLoading extends WaterTrackerState {}

final class WaterTrackerLoaded extends WaterTrackerState {
  final int totalMl;
  final int goalMl;
  final List<WaterIntake> intakes;
  final WaterGoalSettings settings;

  WaterTrackerLoaded({
    required this.totalMl,
    required this.goalMl,
    required this.intakes,
    required this.settings,
  });

  double get progress => goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.0) : 0.0;
}

// ✅ THÊM: State khi đạt goal
final class WaterGoalAchieved extends WaterTrackerState {
  final int totalMl;
  final int goalMl;

  WaterGoalAchieved({required this.totalMl, required this.goalMl});
}

final class WaterTrackerError extends WaterTrackerState {
  final String message;
  WaterTrackerError(this.message);
}
