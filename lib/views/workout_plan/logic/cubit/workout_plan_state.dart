part of 'workout_plan_cubit.dart';

@immutable
sealed class WorkoutPlanState {}

final class WorkoutPlanInitial extends WorkoutPlanState {}

final class WorkoutPlanLoading extends WorkoutPlanState {
  final String message;
  WorkoutPlanLoading(this.message);
}

final class WorkoutPlanLoaded extends WorkoutPlanState {
  final WorkoutPlan plan;
  WorkoutPlanLoaded(this.plan);
}

final class WorkoutPlanError extends WorkoutPlanState {
  final String message;
  WorkoutPlanError(this.message);
}

/// ✅ State mới: Plan đã hết hạn
final class WorkoutPlanExpired extends WorkoutPlanState {
  final String message;
  WorkoutPlanExpired(this.message);
}

final class ActivityLevelsLoading extends WorkoutPlanState {}

final class ActivityLevelsLoaded extends WorkoutPlanState {
  final List<ActivityLevel> levels;
  ActivityLevelsLoaded(this.levels);
}

// ========== WORKOUT SESSION STATES ==========

/// Workout đang bắt đầu
final class WorkoutStarted extends WorkoutPlanState {
  final int dayNumber;
  WorkoutStarted(this.dayNumber);
}

/// Timer tick (mỗi giây)
final class WorkoutTimerTick extends WorkoutPlanState {
  final int elapsedSeconds;
  WorkoutTimerTick(this.elapsedSeconds);
}

/// Workout đã tạm dừng
final class WorkoutPaused extends WorkoutPlanState {
  final int dayNumber;
  final int elapsedSeconds;
  WorkoutPaused(this.dayNumber, this.elapsedSeconds);
}

/// Workout tiếp tục
final class WorkoutResumed extends WorkoutPlanState {
  final int dayNumber;
  final int elapsedSeconds;
  WorkoutResumed(this.dayNumber, this.elapsedSeconds);
}

/// Hoàn thành workout của 1 ngày
final class WorkoutDayCompleted extends WorkoutPlanState {
  final int dayNumber;
  final int durationSeconds;
  WorkoutDayCompleted(this.dayNumber, this.durationSeconds);
}

/// Hoàn thành toàn bộ workout plan (7 ngày)
final class WorkoutPlanCompleted extends WorkoutPlanState {
  final WorkoutPlanProgress progress;
  WorkoutPlanCompleted(this.progress);
}
