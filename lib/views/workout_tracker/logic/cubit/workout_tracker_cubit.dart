import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/device.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';

part 'workout_tracker_state.dart';

class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial()) {
    _autoLoadInitialData();
  }

  final _supabase = Supabase.instance.client;

  // ============ Cache Storage ============
  List<UpcomingWorkout>? _cachedUpcomingWorkouts;
  List<double>? _cachedWeeklyStats;
  Map<String, Map<String, WorkoutProgress>>? _cachedProgress = {};
  List<ExerciseCategory>? _cachedCategories;
  List<ExerciseCategory>? _cachedGymCategories;
  List<ExerciseCategory>? _cachedHomeCategories;
  Map<String, int>? _cachedExerciseCounts;
  Map<String, Map<String, WorkoutProgress>>? _cachedCategoryProgress;

  // ============ Public Getters ============
  List<UpcomingWorkout>? get cachedUpcomingWorkouts => _cachedUpcomingWorkouts;
  List<double>? get cachedWeeklyStats => _cachedWeeklyStats;
  List<ExerciseCategory>? get cachedCategories => _cachedCategories;
  List<ExerciseCategory>? get cachedGymCategories => _cachedGymCategories;
  List<ExerciseCategory>? get cachedHomeCategories => _cachedHomeCategories;
  Map<String, int>? get cachedExerciseCounts => _cachedExerciseCounts;
  Map<String, Map<String, WorkoutProgress>>? get cachedCategoryProgress =>
      _cachedCategoryProgress;

  Future<void> _autoLoadInitialData() async {
    await Future.wait([
      loadUpcomingWorkouts(forceRefresh: false),
      loadWeeklyWorkoutStats(forceRefresh: false),
    ]);
  }

  @override
  Future<void> close() async {
    return super.close();
  }

  void forceCleanCache() {
    _cachedUpcomingWorkouts = null;
    _cachedWeeklyStats = null;
    _cachedProgress = {};
    _cachedCategories = null;
    _cachedGymCategories = null;
    _cachedHomeCategories = null;
    _cachedExerciseCounts = null;
    _cachedCategoryProgress = null;
  }

  // ============================================================
  // PROGRESS TRACKING
  // ============================================================

  Future<Map<String, WorkoutProgress>> loadProgress(
    String categoryId, {
    bool emitState = false,
  }) async {
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

      _cachedProgress?[categoryId] = progressMap;

      if (emitState) {
        emit(DataRefreshed());
      }

      return progressMap;
    } catch (e) {
      return {};
    }
  }

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
  // ============================================================
  // EXERCISE CATEGORIES - With Caching
  // ============================================================

  /// Load tất cả exercise categories với cache
  Future<List<ExerciseCategory>> loadExerciseCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final response = await _supabase.from('exercise_categories').select();
      final categories = response
          .map((json) => ExerciseCategory.fromJson(json))
          .toList();

      categories.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      _cachedCategories = categories;
      _cachedGymCategories = categories.where((c) => c.isGymCategory).toList();
      _cachedHomeCategories = categories
          .where((c) => c.isHomeCategory)
          .toList();

      return categories;
    } catch (e) {
      print('❌ Error loading categories: $e');
      return _cachedCategories ?? [];
    }
  }

  /// Load gym categories with pre-loaded counts and progress
  Future<List<ExerciseCategory>> loadGymCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedGymCategories != null) {
      return _cachedGymCategories!;
    }

    final categories = await loadExerciseCategories(forceRefresh: forceRefresh);
    final gymCategories = categories.where((c) => c.isGymCategory).toList();

    // Pre-load counts and progress for all gym categories
    await _preloadCategoryData(gymCategories);

    return gymCategories;
  }

  /// Load home categories with pre-loaded counts and progress
  Future<List<ExerciseCategory>> loadHomeCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedHomeCategories != null) {
      return _cachedHomeCategories!;
    }

    final categories = await loadExerciseCategories(forceRefresh: forceRefresh);
    final homeCategories = categories.where((c) => c.isHomeCategory).toList();

    // Pre-load counts and progress for all home categories
    await _preloadCategoryData(homeCategories);

    return homeCategories;
  }

  /// Pre-loads exercise counts and progress for all categories
  Future<void> _preloadCategoryData(List<ExerciseCategory> categories) async {
    _cachedExerciseCounts ??= {};
    _cachedCategoryProgress ??= {};

    await Future.wait(
      categories.map((category) async {
        final categoryId = category.id ?? '';
        if (categoryId.isEmpty) return;

        // Load count and progress in parallel
        final results = await Future.wait([
          getExerciseCount(categoryId),
          loadProgress(categoryId),
        ]);

        _cachedExerciseCounts![categoryId] = results[0] as int;
        _cachedCategoryProgress![categoryId] =
            results[1] as Map<String, WorkoutProgress>;
      }),
    );
  }

  // ============================================================
  // LEGACY STREAM METHODS - Giữ lại để backward compatibility
  // ============================================================

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

  Stream<List<ExerciseCategory>> streamGymCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isGymCategory).toList();
    });
  }

  Stream<List<ExerciseCategory>> streamHomeCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isHomeCategory).toList();
    });
  }

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
  // ============================================================

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
  // STATISTICS - STREAM VERSION
  // ============================================================

  Stream<List<UpcomingWorkout>> streamUpcomingWorkouts() {
    final userId = _getUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    // ✅ Đổi từ 5 giây thành:
    // - 2 giây: real-time hơn nhưng tốn tài nguyên
    // - 10 giây: tiết kiệm hơn nhưng chậm hơn
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      return await _fetchUpcomingWorkouts(userId);
    });
  }

  Future<List<UpcomingWorkout>> _fetchUpcomingWorkouts(String userId) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('scheduled_workouts')
        .select('''
          *,
          exercise_categories!inner(
            title_ex,
            title_ex_en,
            img_url
          )
        ''')
        .eq('for_user', userId)
        .eq('is_completed', false)
        .gte('scheduled_time', now.toIso8601String())
        .order('scheduled_time')
        .limit(3);

    return await _buildUpcomingWorkoutsList(response);
  }

  Future<List<UpcomingWorkout>> loadUpcomingWorkouts({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedUpcomingWorkouts != null) {
      emit(UpcomingWorkoutsUpdated(_cachedUpcomingWorkouts!));
      return _cachedUpcomingWorkouts!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) {
        return [];
      }

      final now = DateTime.now();

      final response = await _supabase
          .from('scheduled_workouts')
          .select('''
            *,
            exercise_categories!inner(
              title_ex,
              title_ex_en,
              img_url
            )
          ''')
          .eq('for_user', userId)
          .eq('is_completed', false)
          .gte('scheduled_time', now.toIso8601String())
          .order('scheduled_time')
          .limit(3);

      final upcomingList = await _buildUpcomingWorkoutsList(response);

      _cachedUpcomingWorkouts = upcomingList;

      emit(UpcomingWorkoutsUpdated(upcomingList));

      return upcomingList;
    } catch (e, stackTrace) {
      if (_cachedUpcomingWorkouts != null) {
        return _cachedUpcomingWorkouts!;
      }

      return [];
    }
  }

  Future<List<double>> loadWeeklyWorkoutStats({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedWeeklyStats != null) {
      return _cachedWeeklyStats!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) {
        return List.filled(7, 0.0);
      }

      final now = DateTime.now();

      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday % 7),
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

      emit(WeeklyStatsUpdated(stats));

      return stats;
    } catch (e, stackTrace) {
      return List.filled(7, 0.0);
    }
  }

  // ============================================================
  // NOTIFICATION MANAGEMENT
  // ============================================================

  /// Generates unique notification ID for workout
  int generateNotificationId(String userId, String categoryId) {
    return 200000 +
        (userId.hashCode.abs() % 10000) +
        (categoryId.hashCode.abs() % 10000);
  }

  /// Enables notification for a scheduled workout
  Future<bool> enableWorkoutNotification({
    required String categoryId,
    required String categoryName,
    required DateTime scheduledTime,
    required Function(int, String, String, DateTime) scheduleCallback,
  }) async {
    try {
      final userId = _getUserId();
      if (userId == null) return false;

      final notificationId = generateNotificationId(userId, categoryId);

      await scheduleCallback(
        notificationId,
        'Workout Time',
        '$categoryName - Start Now',
        scheduledTime,
      );

      await _supabase
          .from('scheduled_workouts')
          .update({'has_notification': true})
          .eq('for_user', userId)
          .eq('category_id', categoryId);

      await loadUpcomingWorkouts(forceRefresh: true);

      return true;
    } catch (e) {
      print('❌ Error enabling notification: $e');
      return false;
    }
  }

  /// Disables notification for a scheduled workout
  Future<bool> disableWorkoutNotification({
    required String categoryId,
    required Function(int) cancelCallback,
  }) async {
    try {
      final userId = _getUserId();
      if (userId == null) return false;

      final notificationId = generateNotificationId(userId, categoryId);
      await cancelCallback(notificationId);

      await _supabase
          .from('scheduled_workouts')
          .update({'has_notification': false})
          .eq('for_user', userId)
          .eq('category_id', categoryId);

      await loadUpcomingWorkouts(forceRefresh: true);

      return true;
    } catch (e) {
      print('❌ Error disabling notification: $e');
      return false;
    }
  }

  /// Deletes a scheduled workout
  Future<bool> deleteScheduledWorkout(String categoryId) async {
    try {
      final userId = _getUserId();
      if (userId == null) return false;

      final scheduleResponse = await _supabase
          .from('scheduled_workouts')
          .select('id')
          .eq('for_user', userId)
          .eq('category_id', categoryId)
          .single();

      final scheduleId = scheduleResponse['id'] as String;

      await _supabase.from('scheduled_workouts').delete().eq('id', scheduleId);

      await loadUpcomingWorkouts(forceRefresh: true);

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  String? _getUserId() => _supabase.auth.currentUser?.id;

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

  Future<List<UpcomingWorkout>> _buildUpcomingWorkoutsList(
    List<dynamic> response,
  ) async {
    final List<UpcomingWorkout> upcomingList = [];

    for (var schedule in response) {
      final categoryId = schedule['category_id'];
      if (categoryId == null || categoryId.toString().isEmpty) continue;

      final categoryData = schedule['exercise_categories'];
      if (categoryData == null) continue;

      final category = ExerciseCategory.fromJson(categoryData);
      final categoryName = category.localizedTitleEx;
      final imageUrl = categoryData['img_url'] ?? '';

      final exercisesCount = await getExerciseCount(categoryId);
      if (exercisesCount == 0) continue;

      final progressMap = await loadProgress(categoryId);
      final completedCount = progressMap.values
          .where((p) => p.isFullyCompleted)
          .length;

      final scheduledTimeStr = schedule['scheduled_time'];
      if (scheduledTimeStr == null) continue;

      DateTime scheduledTime;
      try {
        scheduledTime = DateTime.parse(scheduledTimeStr);
      } catch (e) {
        continue;
      }

      if (scheduledTime.isBefore(DateTime.now())) continue;

      upcomingList.add(
        UpcomingWorkout(
          categoryId: categoryId,
          categoryName: categoryName,
          imageUrl: imageUrl,
          scheduledTime: scheduledTime,
          totalExercises: exercisesCount,
          completedExercises: completedCount,
          isNotificationEnabled: schedule['has_notification'] ?? false,
        ),
      );
    }

    return upcomingList;
  }

  List<double> _calculateWeeklyStats(List<dynamic> response) {
    final stats = List<double>.filled(7, 0.0);
    final counts = List<int>.filled(7, 0);

    for (var record in response) {
      try {
        final createdAtStr = record['created_at'];
        if (createdAtStr == null) continue;

        final createdAt = DateTime.parse(createdAtStr);
        final dayIndex = createdAt.weekday % 7;

        final completed = (record['completed_exercises'] ?? 0) as int;
        final total = (record['total_exercises'] ?? 1) as int;

        if (total == 0) continue;

        final percent = (completed / total) * 100;

        stats[dayIndex] += percent;
        counts[dayIndex]++;
      } catch (e) {
        continue;
      }
    }

    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0) {
        stats[i] = (stats[i] / counts[i]).clamp(0.0, 100.0);
      }
    }

    return stats;
  }
}
