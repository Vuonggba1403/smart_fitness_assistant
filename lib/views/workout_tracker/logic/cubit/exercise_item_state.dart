part of 'exercise_item_cubit.dart';

@immutable
sealed class ExerciseItemState {}

final class ExerciseItemInitial extends ExerciseItemState {}

final class ExerciseItemExpandedState extends ExerciseItemState {
  final bool isExpanded;
  ExerciseItemExpandedState(this.isExpanded);
}
