part of 'workout_tracker_cubit.dart';

@immutable
sealed class WorkoutTrackerState {}

/// Trạng thái khởi tạo ban đầu
final class WorkoutTrackerInitial extends WorkoutTrackerState {}

/// Trạng thái khi có thay đổi toggle workout
final class WorkoutToggleChanged extends WorkoutTrackerState {
  final Map<int, bool> toggleStates;
  WorkoutToggleChanged(this.toggleStates);
}

// ============ Các State cho Exercise Categories ============

final class ExerciseCategoriesLoading extends WorkoutTrackerState {}

final class ExerciseCategoriesLoaded extends WorkoutTrackerState {
  final List<ExerciseCategory> categories;
  ExerciseCategoriesLoaded(this.categories);
}

final class ExerciseCategoriesError extends WorkoutTrackerState {
  final String message;
  ExerciseCategoriesError(this.message);
}

// ============ Các State cho Workout Detail ============

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

// ============ Các State cho Exercise Session ============

final class ExerciseSessionActive extends WorkoutTrackerState {
  final List<ExerciseItem> exercises;
  final int currentExerciseIndex;
  final List<WorkoutSet> sets;
  final int elapsedSeconds;
  final bool isExpanded;
  final bool isFinishMode;
  final String categoryId;
  final String categoryName;

  ExerciseSessionActive({
    required this.exercises,
    required this.currentExerciseIndex,
    required this.sets,
    this.elapsedSeconds = 0,
    this.isExpanded = true,
    this.isFinishMode = false,
    required this.categoryId,
    required this.categoryName,
  });

  ExerciseItem get currentExercise => exercises[currentExerciseIndex];
  bool get hasNextExercise => currentExerciseIndex < exercises.length - 1;
  bool get hasPreviousExercise => currentExerciseIndex > 0;
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

  ExerciseSessionActive copyWith({
    List<ExerciseItem>? exercises,
    int? currentExerciseIndex,
    List<WorkoutSet>? sets,
    int? elapsedSeconds,
    bool? isExpanded,
    bool? isFinishMode,
    String? categoryId,
    String? categoryName,
  }) {
    return ExerciseSessionActive(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      sets: sets ?? this.sets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isExpanded: isExpanded ?? this.isExpanded,
      isFinishMode: isFinishMode ?? this.isFinishMode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

// ============ ✅ State cho Schedule (từ schedule_cubit.dart) ============

final class ScheduleLoading extends WorkoutTrackerState {}

final class ScheduleLoaded extends WorkoutTrackerState {
  final List<ScheduledWorkout> schedules;
  final DateTime selectedDate;

  ScheduleLoaded(this.schedules, this.selectedDate);
}

final class ScheduleError extends WorkoutTrackerState {
  final String message;
  ScheduleError(this.message);
}

// ============ ✅ State cho Exercise Item Expansion ============

final class ExerciseItemExpanded extends WorkoutTrackerState {
  final String exerciseId;
  final bool isExpanded;

  ExerciseItemExpanded(this.exerciseId, this.isExpanded);
}

// ✅ THÊM: State cho việc update data
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
