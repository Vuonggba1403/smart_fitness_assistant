part of 'sleep_tracker_cubit.dart';

@immutable
sealed class SleepTrackerState {}

final class SleepTrackerInitial extends SleepTrackerState {}

final class SleepScheduleToggleChanged extends SleepTrackerState {
  final Map<int, bool> toggleStates;
  SleepScheduleToggleChanged(this.toggleStates);
}
