import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart'; // ✅ Bỏ _models
import 'package:smart_fitness_assistant/core/models/exercise_item.dart'; // ✅ Bỏ _models
import 'package:smart_fitness_assistant/core/models/device.dart'; // ✅ Bỏ _models
import 'package:smart_fitness_assistant/core/models/workout_set.dart';
import 'package:smart_fitness_assistant/core/models/workout_session.dart';

part 'workout_tracker_state.dart';

/// Cubit quản lý trạng thái của màn hình Workout Tracker
/// Bao gồm cả logic cho màn hình workout detail
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  /// Map lưu trữ trạng thái toggle của các workout
  final Map<int, bool> _toggleStates = {};

  /// Instance của Supabase client để gọi API
  final _supabase = Supabase.instance.client;

  Timer? _sessionTimer;

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }

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

  /// Tải danh sách exercise items với devices (JOIN version)
  void loadExerciseItems(String categoryId) async {
    emit(WorkoutDetailLoading());

    try {
      final exercisesStream = _supabase
          .from('exercise_items')
          .stream(primaryKey: ['id'])
          .eq('for_cate', categoryId);

      await for (final exercisesData in exercisesStream) {
        if (exercisesData.isEmpty) {
          emit(WorkoutDetailEmpty());
          continue;
        }

        final List<ExerciseItem> exercises = [];

        for (var exerciseJson in exercisesData) {
          final exerciseId = exerciseJson['id'];

          final devicesData = await _supabase
              .from('exercise_devices')
              .select('''
                device_id,
                devices!inner(
                  id,
                  name,
                  img_url
                )
              ''')
              .eq('exercise_id', exerciseId);

          final devices = devicesData
              .map((ed) => ed['devices'])
              .where((d) => d != null)
              .toList();

          exerciseJson['devices'] = devices;
          exercises.add(ExerciseItem.fromJson(exerciseJson));
        }

        // ✅ Sắp xếp theo cột number (tăng dần)
        exercises.sort((a, b) {
          // Nếu một trong hai không có number, đẩy xuống cuối
          if (a.number == null && b.number == null) return 0;
          if (a.number == null) return 1;
          if (b.number == null) return -1;

          return a.number!.compareTo(b.number!);
        });

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

  // ============ Các Method cho Exercise Session ============

  /// Bắt đầu session tập luyện
  void startWorkoutSession(
    List<ExerciseItem> exercises,
    String categoryId,
    String categoryName,
  ) {
    if (exercises.isEmpty) return;

    final initialSets = List.generate(
      4,
      (index) => WorkoutSet(setNumber: index + 1, weight: 8.0, reps: 8),
    );

    emit(
      ExerciseSessionActive(
        exercises: exercises,
        currentExerciseIndex: 0,
        sets: initialSets,
        elapsedSeconds: 0,
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );

    _startTimer();
  }

  /// Bắt đầu đếm thời gian
  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is ExerciseSessionActive) {
        emit(
          currentState.copyWith(
            elapsedSeconds: currentState.elapsedSeconds + 1,
          ),
        );
      }
    });
  }

  /// Dừng session
  void stopWorkoutSession() {
    _sessionTimer?.cancel();
    emit(WorkoutTrackerInitial());
  }

  /// Thêm một set mới
  void addSet() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    final newSet = WorkoutSet(
      setNumber: currentState.sets.length + 1,
      weight: 8.0,
      reps: 8,
    );

    emit(currentState.copyWith(sets: [...currentState.sets, newSet]));
  }

  /// Toggle trạng thái hoàn thành của set
  void toggleSetCompletion(int setIndex) {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    final updatedSets = List<WorkoutSet>.from(currentState.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      isCompleted: !updatedSets[setIndex].isCompleted,
    );

    emit(currentState.copyWith(sets: updatedSets));
  }

  /// Cập nhật weight của set
  void updateSetWeight(int setIndex, double weight) {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    final updatedSets = List<WorkoutSet>.from(currentState.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(weight: weight);

    emit(currentState.copyWith(sets: updatedSets));
  }

  /// Cập nhật reps của set
  void updateSetReps(int setIndex, int reps) {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    final updatedSets = List<WorkoutSet>.from(currentState.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(reps: reps);

    emit(currentState.copyWith(sets: updatedSets));
  }

  /// Chuyển sang exercise tiếp theo
  void nextExercise() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;
    if (!currentState.hasNextExercise) return;

    // Reset sets cho exercise mới
    final newSets = List.generate(
      4,
      (index) => WorkoutSet(setNumber: index + 1, weight: 8.0, reps: 8),
    );

    emit(
      currentState.copyWith(
        currentExerciseIndex: currentState.currentExerciseIndex + 1,
        sets: newSets,
      ),
    );
  }

  /// Toggle expand/collapse exercise card
  void toggleExpanded() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    emit(currentState.copyWith(isExpanded: !currentState.isExpanded));
  }

  /// Bật chế độ kết thúc
  void enableFinishMode() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    emit(currentState.copyWith(isFinishMode: true));
  }

  /// Tắt chế độ kết thúc
  void disableFinishMode() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    emit(currentState.copyWith(isFinishMode: false));
  }

  /// Lưu workout session vào Supabase
  Future<bool> saveWorkoutSession() async {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return false;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Tính toán thống kê
      int totalSets = 0;
      int completedSets = 0;
      final exerciseDetails = <ExerciseSessionDetail>[];

      for (var exercise in currentState.exercises) {
        final sets = currentState.sets
            .map(
              (set) => SetDetail(
                setNumber: set.setNumber,
                weight: set.weight,
                reps: set.reps,
                isCompleted: set.isCompleted,
              ),
            )
            .toList();

        totalSets += sets.length;
        completedSets += sets.where((s) => s.isCompleted).length;

        exerciseDetails.add(
          ExerciseSessionDetail(
            exerciseId: exercise.id,
            exerciseName: exercise.title,
            sets: sets,
          ),
        );
      }

      final session = WorkoutSession(
        forUser: userId,
        categoryId: currentState.categoryId,
        categoryName: currentState.categoryName,
        totalExercises: currentState.exercises.length,
        completedExercises: currentState.currentExerciseIndex + 1,
        totalSets: totalSets,
        completedSets: completedSets,
        durationSeconds: currentState.elapsedSeconds,
        exerciseDetails: exerciseDetails,
      );

      await _supabase.from('workout_sessions').insert(session.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }

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
