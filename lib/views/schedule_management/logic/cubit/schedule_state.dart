part of 'schedule_cubit.dart';

@immutable
sealed class ScheduleState {}

final class ScheduleInitial extends ScheduleState {}

final class ScheduleLoading extends ScheduleState {}

final class ScheduleLoaded extends ScheduleState {
  final List<ScheduledWorkout> schedules;
  final DateTime selectedDate;

  ScheduleLoaded(this.schedules, this.selectedDate);
}

final class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}