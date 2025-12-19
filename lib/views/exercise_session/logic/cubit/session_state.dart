part of 'session_cubit.dart';

@immutable
sealed class SessionState {}

final class SessionInitial extends SessionState {}

final class SessionActive extends SessionState {
  final List<ExerciseItem> exercises;
  final int currentExerciseIndex;
  final List<WorkoutSet> sets;
  final int elapsedSeconds;
  final bool isExpanded;
  final bool isFinishMode;
  final String categoryId;
  final String categoryName;
  final Map<String, bool> exerciseExpandedStates;

  SessionActive({
    required this.exercises,
    required this.currentExerciseIndex,
    required this.sets,
    this.elapsedSeconds = 0,
    this.isExpanded = true,
    this.isFinishMode = false,
    required this.categoryId,
    required this.categoryName,
    Map<String, bool>? exerciseExpandedStates,
  }) : exerciseExpandedStates = exerciseExpandedStates ?? {};

  ExerciseItem get currentExercise => exercises[currentExerciseIndex];
  bool get hasNextExercise => currentExerciseIndex < exercises.length - 1;
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  int get totalSetsOfAllExercises {
    int total = 0;
    for (int i = 0; i < exercises.length; i++) {
      if (i == currentExerciseIndex) {
        total += sets.length;
      } else {
        total += 4;
      }
    }
    return total;
  }

  int get totalCompletedSets {
    final completedExercisesBefore = currentExerciseIndex;
    final completedSetsFromPreviousExercises = completedExercisesBefore * 4;
    return completedSetsFromPreviousExercises + completedSetsCount;
  }

  bool get isCurrentExerciseCompleted => sets.every((s) => s.isCompleted);

  bool get isWorkoutCompleted =>
      currentExerciseIndex == exercises.length - 1 &&
      isCurrentExerciseCompleted;

  bool isExerciseExpanded(String exerciseId) {
    return exerciseExpandedStates[exerciseId] ?? false;
  }

  SessionActive copyWith({
    List<ExerciseItem>? exercises,
    int? currentExerciseIndex,
    List<WorkoutSet>? sets,
    int? elapsedSeconds,
    bool? isExpanded,
    bool? isFinishMode,
    String? categoryId,
    String? categoryName,
    Map<String, bool>? exerciseExpandedStates,
  }) {
    return SessionActive(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      sets: sets ?? this.sets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isExpanded: isExpanded ?? this.isExpanded,
      isFinishMode: isFinishMode ?? this.isFinishMode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      exerciseExpandedStates:
          exerciseExpandedStates ?? this.exerciseExpandedStates,
    );
  }
}

final class SessionSaved extends SessionState {}
