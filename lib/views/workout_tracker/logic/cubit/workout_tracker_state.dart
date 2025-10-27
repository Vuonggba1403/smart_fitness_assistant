part of 'workout_tracker_cubit.dart';

@immutable
sealed class WorkoutTrackerState {}

final class WorkoutTrackerInitial extends WorkoutTrackerState {}

final class WorkoutToggleChanged extends WorkoutTrackerState {
  final Map<int, bool> toggleStates;
  WorkoutToggleChanged(this.toggleStates);
}
