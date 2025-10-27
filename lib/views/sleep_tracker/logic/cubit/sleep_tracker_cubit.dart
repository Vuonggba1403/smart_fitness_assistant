import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'sleep_tracker_state.dart';

class SleepTrackerCubit extends Cubit<SleepTrackerState> {
  SleepTrackerCubit() : super(SleepTrackerInitial());

  final Map<int, bool> _toggleStates = {};

  bool getToggleState(int index) => _toggleStates[index] ?? false;

  void toggleSleepSchedule(int index, bool value) {
    _toggleStates[index] = value;
    emit(SleepScheduleToggleChanged(Map.from(_toggleStates)));
  }
}
