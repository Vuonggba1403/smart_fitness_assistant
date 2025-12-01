import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart'; // ✅ Bỏ _models
import 'package:smart_fitness_assistant/core/models/exercise_item.dart'; // ✅ Bỏ _models
import 'package:smart_fitness_assistant/core/models/device.dart'; // ✅ Bỏ _models

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

  /// Stream danh sách exercise categories
  /// - Sắp xếp theo created_at từ cũ đến mới
  /// - Tự động cập nhật khi có thay đổi trong database
  /// - Số lượng exercises sẽ được tính riêng khi cần hiển thị
  Stream<List<ExerciseCategory>> streamExerciseCategoriesWithCount() {
    return _supabase.from('exercise_categories').stream(primaryKey: ['id']).map(
      (categories) {
        // Parse thành list ExerciseCategory
        final result = categories
            .map((json) => ExerciseCategory.fromJson(json))
            .toList();

        // Sắp xếp theo thời gian tạo tăng dần (cũ → mới)
        result.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });

        return result;
      },
    );
  }

  /// Đếm số lượng exercises của một category
  /// Dùng khi cần hiển thị số lượng exercises
  Future<int> getExerciseCount(String categoryId) async {
    try {
      final response = await _supabase
          .from('exercise_items')
          .select('id')
          .eq('for_cate', categoryId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Tính duration ước tính (3 phút/exercise)
  int calculateDuration(int exerciseCount) {
    return exerciseCount * 3;
  }

  // ============ Các Method cho Workout Detail ============

  /// Tải danh sách exercise items với devices (No RPC version)
  /// - Query exercise_items
  /// - Với mỗi exercise, query devices qua exercise_devices
  void loadExerciseItems(String categoryId) async {
    emit(WorkoutDetailLoading());

    try {
      // Stream exercises
      final exercisesStream = _supabase
          .from('exercise_items')
          .stream(primaryKey: ['id'])
          .eq('for_cate', categoryId);

      await for (final exercisesData in exercisesStream) {
        if (exercisesData.isEmpty) {
          emit(WorkoutDetailEmpty());
          continue;
        }

        // Với mỗi exercise, fetch devices
        final List<ExerciseItem> exercises = [];

        for (var exerciseJson in exercisesData) {
          final exerciseId = exerciseJson['id'];

          // Query devices cho exercise này
          final devicesData = await _supabase
              .from('exercise_devices')
              .select('devices(*)')
              .eq('exercise_id', exerciseId);

          // Extract devices array
          final devices = devicesData
              .map((ed) => ed['devices'])
              .where((d) => d != null)
              .toList();

          // Thêm devices vào exerciseJson
          exerciseJson['devices'] = devices;

          // Parse thành ExerciseItem
          exercises.add(ExerciseItem.fromJson(exerciseJson));
        }

        emit(WorkoutDetailLoaded(exercises));
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
  /// - Giữ nguyên Device object gốc
  List<Device> getUniqueDevices(List<ExerciseItem> exercises) {
    final Map<String, Device> uniqueDevicesMap = {};

    for (var exercise in exercises) {
      for (var device in exercise.devices) {
        final keyLower = device.name
            .toLowerCase(); // ✅ Fix: device.name thay vì device
        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = device; // ✅ Lưu Device object
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
