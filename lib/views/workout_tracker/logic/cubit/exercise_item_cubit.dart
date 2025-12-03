import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'exercise_item_state.dart';

class ExerciseItemCubit extends Cubit<ExerciseItemState> {
  ExerciseItemCubit() : super(ExerciseItemInitial());

  bool _isExpanded = false;

  void toggle() {
    _isExpanded = !_isExpanded;
    emit(ExerciseItemExpandedState(_isExpanded));
  }

  void collapse() {
    _isExpanded = false;
    emit(ExerciseItemExpandedState(false));
  }
}
