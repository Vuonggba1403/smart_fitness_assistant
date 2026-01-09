import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/workout_set.dart';
import 'package:smart_fitness_assistant/core/models/workout_session.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';

part 'session_state.dart';

/// Cubit quản lý phiên tập luyện
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(SessionInitial());

  final _supabase = Supabase.instance.client;
  Timer? _sessionTimer;

  @override
  Future<void> close() async {
    _sessionTimer?.cancel();
    return super.close();
  }

  void startWorkoutSession(
    List<ExerciseItem> exercises,
    String categoryId,
    String categoryName,
  ) {
    if (exercises.isEmpty) return;

    final initialSets = _createDefaultSets();

    emit(
      SessionActive(
        exercises: exercises,
        currentExerciseIndex: 0,
        sets: initialSets,
        elapsedSeconds: 0,
        categoryId: categoryId,
        categoryName: categoryName,
        isExpanded: true,
      ),
    );

    _startTimer();
  }

  void stopWorkoutSession() {
    _sessionTimer?.cancel();
    emit(SessionInitial());
  }

  void addSet() {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final newSet = WorkoutSet(
      setNumber: currentState.sets.length + 1,
      weight: 8.0,
      reps: 8,
    );

    emit(currentState.copyWith(sets: [...currentState.sets, newSet]));
  }

  void toggleSetCompletion(int setIndex) {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final updatedSets = List<WorkoutSet>.from(currentState.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      isCompleted: !updatedSets[setIndex].isCompleted,
    );

    final hasCompletedSet = updatedSets.any((set) => set.isCompleted);

    emit(
      currentState.copyWith(sets: updatedSets, isFinishMode: hasCompletedSet),
    );
  }

  void updateSetWeight(int setIndex, double weight) {
    _updateSetProperty(setIndex, (set) => set.copyWith(weight: weight));
  }

  void updateSetReps(int setIndex, int reps) {
    _updateSetProperty(setIndex, (set) => set.copyWith(reps: reps));
  }

  void nextSet() {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final currentSetIndex = currentState.sets.indexWhere((s) => !s.isCompleted);

    if (currentSetIndex != -1) {
      _completeCurrentSet(currentState, currentSetIndex);
      return;
    }

    if (currentState.hasNextExercise) {
      _moveToNextExercise(currentState);
    } else {
      _finishWorkout();
    }
  }

  void enableFinishMode() {
    _updateAllSetsCompletion(true);
  }

  void disableFinishMode() {
    _updateAllSetsCompletion(false);
  }

  void toggleExpanded() {
    final currentState = state;
    if (currentState is! SessionActive) return;

    emit(currentState.copyWith(isExpanded: !currentState.isExpanded));
  }

  void toggleExerciseItemExpansion(String exerciseId) {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final updatedStates = Map<String, bool>.from(
      currentState.exerciseExpandedStates,
    );
    updatedStates[exerciseId] = !(updatedStates[exerciseId] ?? false);

    emit(currentState.copyWith(exerciseExpandedStates: updatedStates));
  }

  bool isExerciseItemExpanded(String exerciseId) {
    final currentState = state;
    if (currentState is! SessionActive) return false;
    return currentState.isExerciseExpanded(exerciseId);
  }

  /// Lưu phiên tập luyện
  Future<bool> saveWorkoutSession() async {
    final currentState = state;
    if (currentState is! SessionActive) {
      print('❌ ERROR: State is not SessionActive');
      return false;
    }

    try {
      final userId = _getUserId();
      if (userId == null) {
        print('❌ ERROR: User is not authenticated');
        return false;
      }

      await _saveWorkoutProgress(currentState, userId);

      final sessionData = _buildSessionData(currentState, userId);
      final response = await _supabase
          .from('history_workout')
          .insert(sessionData)
          .select();

      print('✅ Insert successful: $response');

      // ✅ FIX: Emit SessionSaved
      emit(SessionSaved());

      return true;
    } catch (e, stackTrace) {
      print('❌ ERROR saving workout session:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  // ============ Private Helpers ============

  String? _getUserId() => _supabase.auth.currentUser?.id;

  List<WorkoutSet> _createDefaultSets() {
    return List.generate(
      4,
      (index) => WorkoutSet(setNumber: index + 1, weight: 8.0, reps: 8),
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is SessionActive) {
        emit(
          currentState.copyWith(
            elapsedSeconds: currentState.elapsedSeconds + 1,
          ),
        );
      }
    });
  }

  void _updateSetProperty(
    int setIndex,
    WorkoutSet Function(WorkoutSet) updater,
  ) {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final updatedSets = List<WorkoutSet>.from(currentState.sets);
    updatedSets[setIndex] = updater(updatedSets[setIndex]);

    emit(currentState.copyWith(sets: updatedSets));
  }

  void _completeCurrentSet(SessionActive state, int setIndex) {
    final updatedSets = List<WorkoutSet>.from(state.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(isCompleted: true);
    emit(state.copyWith(sets: updatedSets));
  }

  void _moveToNextExercise(SessionActive state) {
    final nextIndex = state.currentExerciseIndex + 1;
    final newSets = _createDefaultSets();

    emit(
      state.copyWith(
        currentExerciseIndex: nextIndex,
        sets: newSets,
        isFinishMode: false,
      ),
    );
  }

  void _updateAllSetsCompletion(bool isCompleted) {
    final currentState = state;
    if (currentState is! SessionActive) return;

    final updatedSets = currentState.sets.map((set) {
      return set.copyWith(isCompleted: isCompleted);
    }).toList();

    emit(currentState.copyWith(isFinishMode: isCompleted, sets: updatedSets));
  }

  Future<void> _finishWorkout() async {
    final saved = await saveWorkoutSession();
    if (saved) {
      stopWorkoutSession();
    }
  }

  Future<void> _saveWorkoutProgress(SessionActive state, String userId) async {
    try {
      for (int i = 0; i < state.exercises.length; i++) {
        final exercise = state.exercises[i];
        final (completedSets, totalSets) = _calculateExerciseProgress(state, i);

        final progress = WorkoutProgress(
          forUser: userId,
          categoryId: state.categoryId,
          exerciseId: exercise.id,
          completedSets: completedSets,
          totalSets: totalSets,
          isFullyCompleted: completedSets == totalSets,
        );

        await _supabase
            .from('workout_progress')
            .upsert(
              progress.toJson(),
              onConflict: 'for_user,for_category,for_exercise',
            );
      }
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  (int, int) _calculateExerciseProgress(SessionActive state, int index) {
    if (index < state.currentExerciseIndex) {
      return (4, 4);
    } else if (index == state.currentExerciseIndex) {
      return (state.completedSetsCount, state.sets.length);
    } else {
      return (0, 4);
    }
  }

  Map<String, dynamic> _buildSessionData(SessionActive state, String userId) {
    int totalSets = 0;
    int completedSets = 0;
    int completedExercises = 0;
    final exerciseDetails = <ExerciseSessionDetail>[];

    for (int i = 0; i < state.exercises.length; i++) {
      final exercise = state.exercises[i];
      final sets = _getSetsForExerciseIndex(state, i);

      final setDetails = sets
          .map(
            (set) => SetDetail(
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.reps,
              isCompleted: set.isCompleted,
            ),
          )
          .toList();

      totalSets += setDetails.length;
      completedSets += setDetails.where((s) => s.isCompleted).length;

      if (setDetails.isNotEmpty && setDetails.every((s) => s.isCompleted)) {
        completedExercises++;
      }

      exerciseDetails.add(
        ExerciseSessionDetail(
          exerciseId: exercise.id,
          exerciseName: exercise.localizedTitle,
          sets: setDetails,
        ),
      );
    }

    return {
      'for_user': userId,
      'category_id': state.categoryId,
      'total_exercises': state.exercises.length,
      'completed_exercises': completedExercises,
      'total_sets': totalSets,
      'completed_sets': completedSets,
      'duration_seconds': state.elapsedSeconds,
      'exercise_details': exerciseDetails.map((e) => e.toJson()).toList(),
    };
  }

  List<WorkoutSet> _getSetsForExerciseIndex(SessionActive state, int index) {
    if (index == state.currentExerciseIndex) {
      return state.sets;
    } else if (index < state.currentExerciseIndex) {
      return List.generate(
        4,
        (i) => WorkoutSet(
          setNumber: i + 1,
          weight: 8.0,
          reps: 8,
          isCompleted: true,
        ),
      );
    } else {
      return List.generate(
        4,
        (i) => WorkoutSet(
          setNumber: i + 1,
          weight: 8.0,
          reps: 8,
          isCompleted: false,
        ),
      );
    }
  }
}
