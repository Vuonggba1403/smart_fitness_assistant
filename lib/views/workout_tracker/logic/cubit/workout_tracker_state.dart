part of 'workout_tracker_cubit.dart';

@immutable
sealed class WorkoutTrackerState {}

final class WorkoutTrackerInitial extends WorkoutTrackerState {}

// ============ Exercise Categories States ============

final class ExerciseCategoriesLoading extends WorkoutTrackerState {}

final class ExerciseCategoriesLoaded extends WorkoutTrackerState {
  final List<ExerciseCategory> categories;
  ExerciseCategoriesLoaded(this.categories);
}

final class ExerciseCategoriesError extends WorkoutTrackerState {
  final String message;
  ExerciseCategoriesError(this.message);
}

// ============ Workout Detail States ============

final class WorkoutDetailLoading extends WorkoutTrackerState {}

final class WorkoutDetailLoaded extends WorkoutTrackerState {
  final List<ExerciseItem> exercises;

  WorkoutDetailLoaded(this.exercises);

  int get exerciseCount => exercises.length;
  bool get hasExercises => exercises.isNotEmpty;
}

final class WorkoutDetailEmpty extends WorkoutTrackerState {}

final class WorkoutDetailError extends WorkoutTrackerState {
  final String message;
  WorkoutDetailError(this.message);
}

// ============ Statistics & Data Refresh States ============

final class DataRefreshed extends WorkoutTrackerState {
  final DateTime timestamp;
  DataRefreshed() : timestamp = DateTime.now();
}

final class UpcomingWorkoutsUpdated extends WorkoutTrackerState {
  final List<UpcomingWorkout> workouts;
  UpcomingWorkoutsUpdated(this.workouts);
}

final class WeeklyStatsUpdated extends WorkoutTrackerState {
  final List<double> stats;
  WeeklyStatsUpdated(this.stats);
}
