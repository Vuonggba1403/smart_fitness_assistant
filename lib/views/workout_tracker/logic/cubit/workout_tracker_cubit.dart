import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'workout_tracker_state.dart';

class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  final Map<int, bool> _toggleStates = {};

  bool getToggleState(int index) => _toggleStates[index] ?? false;

  void toggleWorkout(int index, bool value) {
    _toggleStates[index] = value;
    emit(WorkoutToggleChanged(Map.from(_toggleStates)));
  }
}
