import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';

part 'workout_tracker_state.dart';

/// Cubit quản lý trạng thái của màn hình Workout Tracker
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  /// Map lưu trữ trạng thái toggle của các workout
  final Map<int, bool> _toggleStates = {};

  /// Instance của Supabase client để gọi API
  final _supabase = Supabase.instance.client;

  /// Lấy trạng thái toggle của workout tại index
  /// Trả về false nếu chưa có trạng thái
  bool getToggleState(int index) => _toggleStates[index] ?? false;

  /// Cập nhật trạng thái toggle của workout
  /// [index] - Vị trí của workout
  /// [value] - Giá trị toggle mới (true/false)
  void toggleWorkout(int index, bool value) {
    _toggleStates[index] = value;
    emit(WorkoutToggleChanged(Map.from(_toggleStates)));
  }

  /// Stream exercise items theo category ID với realtime updates
  /// Returns Stream với list ExerciseItem objects
  Stream<List<ExerciseItem>> streamExerciseItems(String categoryId) {
    return _supabase
        .from('exercise_items')
        .stream(primaryKey: ['id'])
        .eq('for_cate', categoryId)
        .map((data) {
          return data.map((json) => ExerciseItem.fromJson(json)).toList();
        });
  }

  /// Stream exercise categories với exercise count thực tế
  /// Đếm số exercises từ bảng exercise_items
  /// Sắp xếp theo created_at từ cũ đến mới
  Stream<List<ExerciseCategory>> streamExerciseCategoriesWithCount() {
    return _supabase
        .from('exercise_categories')
        .stream(primaryKey: ['id'])
        .asyncMap((categories) async {
          final List<ExerciseCategory> result = [];

          for (var categoryJson in categories) {
            final categoryId = categoryJson['id'];

            // Đếm số lượng exercises thực tế
            final exercisesResponse = await _supabase
                .from('exercise_items')
                .select('id')
                .eq('for_cate', categoryId);

            final exerciseCount = exercisesResponse.length;

            // Tạo ExerciseCategory với count thực tế
            final category = ExerciseCategory.fromJson({
              ...categoryJson,
              'exercise_count': exerciseCount,
              'duration_mins': exerciseCount * 3,
            });

            result.add(category);
          }

          // Sort theo created_at ascending
          result.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return result;
        });
  }

  /// Lấy danh sách devices unique từ exercises
  /// Case-insensitive comparison
  List<String> getUniqueDevices(List<ExerciseItem> exercises) {
    final Map<String, String> uniqueDevicesMap = {};

    for (var exercise in exercises) {
      for (var device in exercise.devices) {
        final keyLower = device.toLowerCase();
        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = device; // Giữ tên gốc
        }
      }
    }

    return uniqueDevicesMap.values.toList();
  }
}
