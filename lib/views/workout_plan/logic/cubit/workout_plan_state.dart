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

final class ActivityLevelsLoading extends WorkoutPlanState {}

final class ActivityLevelsLoaded extends WorkoutPlanState {
  final List<ActivityLevel> levels;
  ActivityLevelsLoaded(this.levels);
}
