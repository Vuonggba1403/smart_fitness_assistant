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

/// Cubit quản lý workout tracking
///
/// Chỉ tập trung vào:
/// - Categories (Gym/Home)
/// - Exercise Detail
/// - Progress Tracking
/// - Statistics (Weekly chart, Upcoming workouts)
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial()) {
    // ✅ FIX: Auto-load data khi cubit được khởi tạo
    _autoLoadInitialData();
  }

  final _supabase = Supabase.instance.client;

  // ============ Cache Storage ============
  List<UpcomingWorkout>? _cachedUpcomingWorkouts;
  List<double>? _cachedWeeklyStats;
  Map<String, Map<String, WorkoutProgress>>? _cachedProgress = {};

  // ============ Public Getters ============
  List<UpcomingWorkout>? get cachedUpcomingWorkouts => _cachedUpcomingWorkouts;
  List<double>? get cachedWeeklyStats => _cachedWeeklyStats;

  // ✅ ADD: Auto-load data khi cubit mount
  Future<void> _autoLoadInitialData() async {
    print('🔄 Auto-loading initial data...');

    // Load parallel để tăng tốc
    await Future.wait([
      loadUpcomingWorkouts(forceRefresh: false),
      loadWeeklyWorkoutStats(forceRefresh: false),
    ]);

    print('✅ Initial data loaded');
  }

  // ✅ FIX: Không clear cache khi close
  @override
  Future<void> close() async {
    print('🔒 Closing WorkoutTrackerCubit (keeping cache)');
    // ❌ REMOVED: clearCache() - giữ cache để persist data
    return super.close();
  }

  // ✅ ADD: Method để manual clear cache nếu cần
  void forceCleanCache() {
    print('🧹 Force cleaning cache');
    _cachedUpcomingWorkouts = null;
    _cachedWeeklyStats = null;
    _cachedProgress = {};
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
      print('❌ Error loading progress: $e');
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
  // STATISTICS
  // ============================================================

  Future<List<UpcomingWorkout>> loadUpcomingWorkouts({
    bool forceRefresh = false,
  }) async {
    print('📅 Loading upcoming workouts (force: $forceRefresh)');

    // ✅ FIX: Return cache nếu có và không force refresh
    if (!forceRefresh && _cachedUpcomingWorkouts != null) {
      print('✅ Using cached data: ${_cachedUpcomingWorkouts!.length} workouts');

      // ✅ Emit state để trigger UI update
      emit(UpcomingWorkoutsUpdated(_cachedUpcomingWorkouts!));

      return _cachedUpcomingWorkouts!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) {
        print('❌ User not authenticated');
        return [];
      }

      final now = DateTime.now();

      final response = await _supabase
          .from('scheduled_workouts')
          .select('''
            *,
            exercise_categories!inner(
              title_ex,
              img_url
            )
          ''')
          .eq('for_user', userId)
          .eq('is_completed', false)
          .gte('scheduled_time', now.toIso8601String())
          .order('scheduled_time')
          .limit(3);

      final upcomingList = await _buildUpcomingWorkoutsList(response);

      // ✅ Save cache
      _cachedUpcomingWorkouts = upcomingList;

      print('✅ Loaded ${upcomingList.length} upcoming workouts');

      // ✅ Emit state
      emit(UpcomingWorkoutsUpdated(upcomingList));

      return upcomingList;
    } catch (e, stackTrace) {
      print('❌ Error loading upcoming workouts: $e');
      print('StackTrace: $stackTrace');

      // ✅ Return cached data nếu có lỗi
      if (_cachedUpcomingWorkouts != null) {
        print('⚠️ Using stale cache due to error');
        return _cachedUpcomingWorkouts!;
      }

      return [];
    }
  }

  Future<List<double>> loadWeeklyWorkoutStats({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedWeeklyStats != null) {
      print('✅ Using cached stats');
      return _cachedWeeklyStats!;
    }

    try {
      final userId = _getUserId();
      if (userId == null) {
        print('❌ User not authenticated');
        return List.filled(7, 0.0);
      }

      final now = DateTime.now();

      // ✅ FIX: Tính start of week (Sunday = 0)
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday % 7),
      );

      print('📅 Querying history from: ${startOfWeek.toIso8601String()}');

      // ✅ FIX: Query đúng tên cột
      final response = await _supabase
          .from('history_workout')
          .select('created_at, completed_exercises, total_exercises')
          .eq('for_user', userId)
          .gte('created_at', startOfWeek.toIso8601String())
          .lte('created_at', now.toIso8601String())
          .order('created_at');

      print('📊 Found ${response.length} workout records');

      final stats = _calculateWeeklyStats(response);
      _cachedWeeklyStats = stats;

      emit(WeeklyStatsUpdated(stats));

      return stats;
    } catch (e, stackTrace) {
      print('❌ Error loading weekly stats: $e');
      print('StackTrace: $stackTrace');
      return List.filled(7, 0.0);
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

      final categoryName = categoryData['title_ex'] ?? 'Workout';
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

  /// Tính weekly stats từ history_workout
  List<double> _calculateWeeklyStats(List<dynamic> response) {
    // ✅ stats[0] = Sunday, stats[1] = Monday, ..., stats[6] = Saturday
    final stats = List<double>.filled(7, 0.0);
    final counts = List<int>.filled(7, 0);

    print('📊 Calculating stats for ${response.length} records');

    for (var record in response) {
      try {
        final createdAtStr = record['created_at'];
        if (createdAtStr == null) continue;

        final createdAt = DateTime.parse(createdAtStr);

        // ✅ FIX: weekday % 7 → 0=Sunday, 1=Monday, ..., 6=Saturday
        final dayIndex = createdAt.weekday % 7;

        final completed = (record['completed_exercises'] ?? 0) as int;
        final total = (record['total_exercises'] ?? 1) as int;

        if (total == 0) continue;

        final percent = (completed / total) * 100;

        stats[dayIndex] += percent;
        counts[dayIndex]++;

        print(
          '  ✓ Day $dayIndex: $completed/$total = ${percent.toStringAsFixed(1)}%',
        );
      } catch (e) {
        print('  ⚠️ Error processing record: $e');
        continue;
      }
    }

    // Tính trung bình cho mỗi ngày
    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0) {
        stats[i] = (stats[i] / counts[i]).clamp(0.0, 100.0);
      }
      print(
        '  → Day $i: ${stats[i].toStringAsFixed(1)}% (${counts[i]} sessions)',
      );
    }

    return stats;
  }
}
