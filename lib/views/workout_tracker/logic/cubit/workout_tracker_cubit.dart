import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';

part 'workout_tracker_state.dart';

/// Cubit quản lý trạng thái của màn hình Workout Tracker
/// Bao gồm cả logic cho màn hình workout detail
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  /// Map lưu trữ trạng thái toggle của các workout
  final Map<int, bool> _toggleStates = {};

  /// Instance của Supabase client để gọi API
  final _supabase = Supabase.instance.client;

  // ============ Các Method cho Toggle ============

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

  // ============ Các Method cho Categories ============

  /// Stream danh sách exercise categories với số lượng exercises thực tế
  /// - Đếm số exercises từ bảng exercise_items
  /// - Sắp xếp theo created_at từ cũ đến mới
  /// - Tự động cập nhật khi có thay đổi trong database
  Stream<List<ExerciseCategory>> streamExerciseCategoriesWithCount() {
    return _supabase
        .from('exercise_categories')
        .stream(primaryKey: ['id'])
        .asyncMap((categories) async {
          final List<ExerciseCategory> result = [];

          for (var categoryJson in categories) {
            final categoryId = categoryJson['id'];

            // Đếm số lượng exercises thực tế từ bảng exercise_items
            final exercisesResponse = await _supabase
                .from('exercise_items')
                .select('id')
                .eq('for_cate', categoryId);

            final exerciseCount = exercisesResponse.length;

            // Tạo ExerciseCategory với số lượng exercises thực tế
            final category = ExerciseCategory.fromJson({
              ...categoryJson,
              'exercise_count': exerciseCount,
              'duration_mins': exerciseCount * 3, // Ước tính 3 phút/exercise
            });

            result.add(category);
          }

          // Sắp xếp theo thời gian tạo tăng dần (cũ → mới)
          result.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return result;
        });
  }

  // ============ Các Method cho Workout Detail ============

  /// Tải danh sách exercise items cho màn hình workout detail
  /// - Emit các state tương ứng: Loading → Loaded/Error/Empty
  /// - Tự động cập nhật realtime khi có thay đổi
  void loadExerciseItems(String categoryId) async {
    emit(WorkoutDetailLoading());

    try {
      final stream = _supabase
          .from('exercise_items')
          .stream(primaryKey: ['id'])
          .eq('for_cate', categoryId)
          .map((data) {
            return data.map((json) => ExerciseItem.fromJson(json)).toList();
          });

      await for (final exercises in stream) {
        if (exercises.isEmpty) {
          emit(WorkoutDetailEmpty());
        } else {
          emit(WorkoutDetailLoaded(exercises));
        }
      }
    } catch (e) {
      emit(WorkoutDetailError(e.toString()));
    }
  }

  /// Stream exercise items theo category ID (không emit state)
  /// Dùng cho trường hợp cần raw stream mà không muốn emit state
  Stream<List<ExerciseItem>> streamExerciseItems(String categoryId) {
    return _supabase
        .from('exercise_items')
        .stream(primaryKey: ['id'])
        .eq('for_cate', categoryId)
        .map((data) {
          return data.map((json) => ExerciseItem.fromJson(json)).toList();
        });
  }

  // ============ Các Helper Methods ============

  /// Lấy danh sách thiết bị unique từ danh sách exercises
  /// - So sánh không phân biệt hoa/thường (case-insensitive)
  /// - Loại bỏ các thiết bị trùng lặp
  /// - Giữ nguyên tên gốc (không convert về lowercase)
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

  /// Lấy exercise đầu tiên có thiết bị để hiển thị ảnh
  /// - Ưu tiên exercise có thiết bị
  /// - Fallback về exercise đầu tiên nếu không có exercise nào có thiết bị
  /// - Trả về null nếu danh sách rỗng
  ExerciseItem? getExerciseWithDevice(List<ExerciseItem> exercises) {
    try {
      return exercises.firstWhere(
        (e) => e.hasEquipment,
        orElse: () => exercises.first,
      );
    } catch (_) {
      return null;
    }
  }
}
