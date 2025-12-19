import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/models/workout_set.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/device.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';

part 'workout_tracker_state.dart';

/// Cubit chính quản lý tất cả các chức năng liên quan đến workout
///
/// Bao gồm:
/// - Quản lý danh mục bài tập (Categories)
/// - Theo dõi tiến độ (Progress)
/// - Thống kê biểu đồ (Statistics)
///
/// ❌ REMOVED: Schedule Management → Chuyển sang ScheduleCubit
/// ❌ REMOVED: Exercise Session → Chuyển sang SessionCubit
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  // ============ Dependencies & Services ============
  final _supabase = Supabase.instance.client;

  // ============ Cache Storage ============
  List<UpcomingWorkout>? _cachedUpcomingWorkouts;
  List<double>? _cachedWeeklyStats;
  Map<String, Map<String, WorkoutProgress>>? _cachedProgress = {};
  final Map<int, bool> _toggleStates = {};

  // ============ Public Getters ============
  List<UpcomingWorkout>? get cachedUpcomingWorkouts => _cachedUpcomingWorkouts;
  List<double>? get cachedWeeklyStats => _cachedWeeklyStats;

  // ============ Lifecycle Methods ============

  @override
  Future<void> close() async {
    return super.close();
  }

  /// Xóa toàn bộ cache
  void clearCache() {
    _cachedUpcomingWorkouts = null;
    _cachedWeeklyStats = null;
    _cachedProgress = {};
  }

  // ============================================================
  // PROGRESS TRACKING
  // Theo dõi và lưu tiến độ tập luyện
  // ============================================================

  /// Tải tiến độ cho một category
  Future<Map<String, WorkoutProgress>> loadProgress(String categoryId) async {
    try {
      final userId = _getUserId();
      if (userId == null) return {};

      final response = await _supabase
          .from('workout_progress')
          .select()
          .eq('for_user', userId)
          .eq('for_category', categoryId);

      final Map<String, WorkoutProgress> progressMap = {};
      for (var json in response) {
        final progress = WorkoutProgress.fromJson(json);
        progressMap[progress.exerciseId] = progress;
      }

      return progressMap;
    } catch (e) {
      print('❌ Error loading progress: $e');
      return {};
    }
  }

  /// Reset tiến độ cho category
  Future<void> resetProgress(String categoryId) async {
    try {
      final userId = _getUserId();
      if (userId == null) return;

      await _supabase
          .from('workout_progress')
          .delete()
          .eq('for_user', userId)
          .eq('for_category', categoryId);
    } catch (e) {
      print('❌ Error resetting progress: $e');
    }
  }

  // ============================================================
  // CATEGORIES
  // Quản lý danh mục bài tập
  // ============================================================

  /// Stream tất cả categories
  Stream<List<ExerciseCategory>> streamExerciseCategoriesWithCount() {
    return _supabase.from('exercise_categories').stream(primaryKey: ['id']).map(
      (categories) {
        final result = categories
            .map((json) => ExerciseCategory.fromJson(json))
            .toList();

        result.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });

        return result;
      },
    );
  }

  /// Stream categories ở gym
  Stream<List<ExerciseCategory>> streamGymCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isGymCategory).toList();
    });
  }

  /// Stream categories ở nhà
  Stream<List<ExerciseCategory>> streamHomeCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isHomeCategory).toList();
    });
  }

  /// Đếm số exercise trong category
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

  // ============================================================
  // WORKOUT DETAIL
  // Tải chi tiết exercises của category
  // ============================================================

  /// Tải danh sách exercises với devices
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

        final exercises = await _buildExercisesWithDevices(exercisesData);
        emit(WorkoutDetailLoaded(exercises));
      }
    } catch (e) {
      emit(WorkoutDetailError(e.toString()));
    }
  }

  /// Lấy danh sách thiết bị unique
  List<Device> getUniqueDevices(List<ExerciseItem> exercises) {
    final Map<String, Device> uniqueDevicesMap = {};

    for (var exercise in exercises) {
      for (var device in exercise.devices) {
        final keyLower = device.name.toLowerCase();
        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = device;
        }
      }
    }

    return uniqueDevicesMap.values.toList();
  }

  /// Lấy exercise có thiết bị
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

  // ============================================================
  // STATISTICS
  // Thống kê và upcoming workouts
  // ============================================================

  /// Tải danh sách upcoming workouts - ✅ EMIT state sau khi load
  Future<List<UpcomingWorkout>> loadUpcomingWorkouts({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedUpcomingWorkouts != null) {
      return _cachedUpcomingWorkouts!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) return [];

      final now = DateTime.now();

      final response = await _supabase
          .from('scheduled_workouts')
          .select()
          .eq('for_user', userId)
          .eq('is_completed', false)
          .gte('scheduled_time', now.toIso8601String())
          .order('scheduled_time')
          .limit(3);

      final upcomingList = await _buildUpcomingWorkoutsList(response);
      _cachedUpcomingWorkouts = upcomingList;

      // ✅ FIX: Emit state để trigger rebuild
      emit(UpcomingWorkoutsUpdated(upcomingList));

      return upcomingList;
    } catch (e) {
      print('❌ Error loading upcoming workouts: $e');
      return [];
    }
  }

  /// Tải thống kê 7 ngày - ✅ EMIT state sau khi load
  Future<List<double>> loadWeeklyWorkoutStats({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedWeeklyStats != null) {
      return _cachedWeeklyStats!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) return List.filled(7, 0.0);

      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day - now.weekday % 7,
      );

      final response = await _supabase
          .from('history_workout')
          .select('created_at, completed_exercises, total_exercises')
          .eq('for_user', userId)
          .gte('created_at', startOfWeek.toIso8601String())
          .lte('created_at', now.toIso8601String())
          .order('created_at');

      final stats = _calculateWeeklyStats(response);
      _cachedWeeklyStats = stats;

      // ✅ FIX: Emit state để trigger rebuild
      emit(WeeklyStatsUpdated(stats));

      return stats;
    } catch (e) {
      print('❌ Error loading weekly stats: $e');
      return List.filled(7, 0.0);
    }
  }

  // ============================================================
  // TOGGLE & UI STATE
  // Quản lý trạng thái UI
  // ============================================================

  /// Lấy trạng thái toggle
  bool getToggleState(int index) => _toggleStates[index] ?? false;

  /// Toggle workout
  void toggleWorkout(int index, bool value) {
    _toggleStates[index] = value;
    emit(WorkoutToggleChanged(Map.from(_toggleStates)));
  }

  // ============================================================
  // PRIVATE HELPER METHODS
  // Các method helper nội bộ
  // ============================================================

  /// Lấy user ID hiện tại
  String? _getUserId() => _supabase.auth.currentUser?.id;

  /// Build exercises với devices
  Future<List<ExerciseItem>> _buildExercisesWithDevices(
    List<dynamic> exercisesData,
  ) async {
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

    return exercises;
  }

  /// Build upcoming workouts list
  Future<List<UpcomingWorkout>> _buildUpcomingWorkoutsList(
    List<dynamic> response,
  ) async {
    final List<UpcomingWorkout> upcomingList = [];

    for (var schedule in response) {
      final categoryId = schedule['category_id'];

      final exercisesCount = await getExerciseCount(categoryId);
      if (exercisesCount == 0) continue;

      final progressMap = await loadProgress(categoryId);
      final completedCount = progressMap.values
          .where((p) => p.isFullyCompleted)
          .length;

      upcomingList.add(
        UpcomingWorkout(
          categoryId: categoryId,
          categoryName: schedule['category_name'],
          imageUrl: schedule['image_url'] ?? '',
          scheduledTime: DateTime.parse(schedule['scheduled_time']),
          totalExercises: exercisesCount,
          completedExercises: completedCount,
          isNotificationEnabled: schedule['has_notification'] ?? false,
        ),
      );
    }

    return upcomingList;
  }

  /// Tính weekly stats
  List<double> _calculateWeeklyStats(List<dynamic> response) {
    final stats = List<double>.filled(7, 0.0);
    final counts = List<int>.filled(7, 0);

    for (var record in response) {
      final createdAt = DateTime.parse(record['created_at']);
      final dayIndex = createdAt.weekday % 7;

      final completed = (record['completed_exercises'] ?? 0) as int;
      final total = (record['total_exercises'] ?? 1) as int;

      final percent = total > 0 ? (completed / total) * 100 : 0.0;

      stats[dayIndex] += percent;
      counts[dayIndex]++;
    }

    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0) {
        stats[i] = (stats[i] / counts[i]).clamp(0.0, 100.0);
      }
    }

    return stats;
  }
}
