import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'exercise_item_state.dart';

class ExerciseItemCubit extends Cubit<ExerciseItemState> {
  ExerciseItemCubit()
    : super(ExerciseItemExpandedState(false)); // ✅ Positional parameter

  void toggle() {
    final currentState = state;
    if (currentState is ExerciseItemExpandedState) {
      emit(ExerciseItemExpandedState(!currentState.isExpanded)); // ✅ Positional
    }
  }

  void expand() {
    emit(ExerciseItemExpandedState(true)); // ✅ Positional
  }

  void collapse() {
    emit(ExerciseItemExpandedState(false)); // ✅ Positional
  }
}
