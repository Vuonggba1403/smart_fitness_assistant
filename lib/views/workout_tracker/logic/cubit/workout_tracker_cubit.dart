import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'workout_tracker_state.dart';

class WorkoutTrackerCubit extends Cubit<Map<String, bool>> {
  WorkoutTrackerCubit() : super({});

  /// Bật/tắt trạng thái của 1 workout
  void toggleWorkout(String id) {
    final current = state[id] ?? false;
    emit({...state, id: !current});
  }

  /// Đặt trạng thái cụ thể (true/false)
  void setWorkout(String id, bool value) {
    emit({...state, id: value});
  }

  /// Kiểm tra trạng thái workout hiện tại
  bool isWorkoutActive(String id) {
    return state[id] ?? false;
  }
}
