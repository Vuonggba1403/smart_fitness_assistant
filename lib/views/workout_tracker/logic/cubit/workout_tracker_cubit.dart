import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/device.dart';
import 'package:smart_fitness_assistant/core/models/workout_set.dart';
import 'package:smart_fitness_assistant/core/models/workout_session.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

part 'workout_tracker_state.dart';

class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  final Map<int, bool> _toggleStates = {};
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  Timer? _sessionTimer;

  // Cache
  List<UpcomingWorkout>? _cachedUpcomingWorkouts;
  List<double>? _cachedWeeklyStats;
  Map<String, Map<String, WorkoutProgress>>? _cachedProgress = {};

  // ✅ THÊM: Map lưu trạng thái expand của từng exercise item
  final Map<String, bool> _exerciseItemExpandedStates = {};

  // ✅ THÊM: Lưu list reminder IDs đã schedule
  final Map<String, int> _scheduledWorkoutReminderIds = {};

  @override
  Future<void> close() async {
    _sessionTimer?.cancel();
    // ✅ Cancel all workout reminders when cubit is closed (logout)
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _cancelUserWorkoutReminders(userId);
    }
    return super.close();
  }

  void clearCache() {
    _cachedUpcomingWorkouts = null;
    _cachedWeeklyStats = null;
    _cachedProgress = {};
  }

  // ============ ✅ Schedule Methods (từ schedule_cubit.dart) ============

  /// Load lịch tập theo ngày
  Future<void> loadSchedulesByDate(DateTime date) async {
    emit(ScheduleLoading());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ScheduleError('User not authenticated'));
        return;
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('scheduled_workouts')
          .select()
          .eq('for_user', userId)
          .gte('scheduled_time', startOfDay.toIso8601String())
          .lt('scheduled_time', endOfDay.toIso8601String())
          .order('scheduled_time');

      final schedules = response
          .map((json) => ScheduledWorkout.fromJson(json))
          .toList();

      emit(ScheduleLoaded(schedules, date));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  /// Thêm lịch tập mới
  Future<bool> addSchedule(ScheduledWorkout schedule) async {
    try {
      final response = await _supabase
          .from('scheduled_workouts')
          .insert(schedule.toJson())
          .select()
          .single();

      final newSchedule = ScheduledWorkout.fromJson(response);

      if (schedule.hasNotification) {
        await _scheduleNotification(newSchedule);
      }

      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error adding schedule: $e');
      return false;
    }
  }

  /// Xóa lịch tập
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase.from('scheduled_workouts').delete().eq('id', scheduleId);
      await _notificationService.cancelNotification(scheduleId.hashCode);

      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  /// Đánh dấu hoàn thành
  Future<bool> markScheduleAsCompleted(String scheduleId) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update({'is_completed': true})
          .eq('id', scheduleId);

      await _notificationService.cancelNotification(scheduleId.hashCode);

      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error marking completed: $e');
      return false;
    }
  }

  /// ✅ Cancel all workout reminders for current user - CHỈ cancel những cái thực tế
  Future<void> _cancelUserWorkoutReminders(String userId) async {
    try {
      // ✅ Chỉ cancel những reminder đã được schedule
      for (final scheduleId in _scheduledWorkoutReminderIds.keys) {
        final notificationId = _scheduledWorkoutReminderIds[scheduleId]!;
        await _notificationService.cancelNotification(notificationId);
        print(
          '❌ Notification $notificationId for schedule $scheduleId cancelled',
        );
      }

      // ✅ Clear map sau khi cancel
      _scheduledWorkoutReminderIds.clear();

      print('✅ Cancelled all workout reminders for user: $userId');
    } catch (e) {
      print('❌ Error cancelling workout reminders: $e');
    }
  }

  /// ✅ Private: Lên lịch notification với user-specific ID
  Future<void> _scheduleNotification(ScheduledWorkout schedule) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // ✅ Generate user-specific notification ID
    final notificationId = _generateWorkoutNotificationId(userId, schedule.id!);

    // ✅ LƯU vào map
    _scheduledWorkoutReminderIds[schedule.id!] = notificationId;

    await _notificationService.scheduleWorkoutNotification(
      id: notificationId,
      title: '⏰ Đã đến giờ tập luyện!',
      body: '${schedule.categoryName} - Bắt đầu ngay thôi! 💪',
      scheduledTime: schedule.scheduledTime,
    );

    print('✅ Workout reminder ID: $notificationId for schedule ${schedule.id}');
  }

  /// ✅ Generate user-specific workout notification ID
  int _generateWorkoutNotificationId(String userId, String scheduleId) {
    final userHash = userId.hashCode.abs() % 10000;
    final scheduleHash = scheduleId.hashCode.abs() % 10000;
    return 200000 + userHash + scheduleHash; // ✅ Khác với water (100000)
  }

  // ============ Toggle Methods ============

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

  // ============ Categories Methods ============

  /// Stream danh sách exercise categories
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

  /// ✅ Stream GYM categories - BỎ DEBUG
  Stream<List<ExerciseCategory>> streamGymCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isGymCategory).toList();
    });
  }

  /// ✅ Stream HOME categories - BỎ DEBUG
  Stream<List<ExerciseCategory>> streamHomeCategories() {
    return streamExerciseCategoriesWithCount().map((categories) {
      return categories.where((c) => c.isHomeCategory).toList();
    });
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

  // ============ Workout Detail Methods ============

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

        // ❌ BỎ sắp xếp theo classify - Giữ nguyên thứ tự từ DB
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

  // ============ Exercise Session Methods ============

  /// Bắt đầu session tập luyện
  void startWorkoutSession(
    List<ExerciseItem> exercises,
    String categoryId,
    String categoryName,
  ) {
    if (exercises.isEmpty) return;

    // Mặc định 4 sets x 8 reps
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
        isExpanded: true, // ✅ MẶC ĐỊNH MỞ RỘNG (expanded)
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

    // ✅ Bật finish mode nếu có ít nhất 1 set được hoàn thành
    final hasCompletedSet = updatedSets.any((set) => set.isCompleted);

    emit(
      currentState.copyWith(
        sets: updatedSets,
        isFinishMode: hasCompletedSet, // ✅ Tự động bật finish mode
      ),
    );
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

  /// Chuyển sang set tiếp theo hoặc exercise tiếp theo
  void nextSet() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    final currentSetIndex = currentState.sets.indexWhere((s) => !s.isCompleted);

    // Nếu còn set chưa hoàn thành, đánh dấu set đó
    if (currentSetIndex != -1) {
      final updatedSets = List<WorkoutSet>.from(currentState.sets);
      updatedSets[currentSetIndex] = updatedSets[currentSetIndex].copyWith(
        isCompleted: true,
      );
      emit(currentState.copyWith(sets: updatedSets));
      return;
    }

    // Nếu đã hoàn thành tất cả sets của exercise hiện tại
    if (currentState.hasNextExercise) {
      // Chuyển sang exercise tiếp theo
      final nextIndex = currentState.currentExerciseIndex + 1;
      final newSets = List.generate(
        4,
        (index) => WorkoutSet(setNumber: index + 1, weight: 8.0, reps: 8),
      );

      // ✅ TẮT finish mode khi chuyển bài tập
      emit(
        currentState.copyWith(
          currentExerciseIndex: nextIndex,
          sets: newSets,
          isFinishMode: false, // ✅ Ẩn nút "Kết thúc"
        ),
      );
    } else {
      // Đã hoàn thành tất cả exercises → Tự động lưu và kết thúc
      _finishWorkout();
    }
  }

  /// Chuyển sang exercise tiếp theo (giữ lại cho trường hợp cần skip)
  void nextExercise() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;
    if (!currentState.hasNextExercise) return;

    final nextIndex = currentState.currentExerciseIndex + 1;
    final newSets = List.generate(
      4,
      (index) => WorkoutSet(setNumber: index + 1, weight: 8.0, reps: 8),
    );

    emit(currentState.copyWith(currentExerciseIndex: nextIndex, sets: newSets));
  }

  /// Toggle expand/collapse exercise card
  void toggleExpanded() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    emit(currentState.copyWith(isExpanded: !currentState.isExpanded));
  }

  /// Bật chế độ kết thúc - Đánh dấu tất cả các set là hoàn thành
  void enableFinishMode() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    // ✅ Đánh dấu tất cả các set hiện tại là hoàn thành
    final updatedSets = currentState.sets.map((set) {
      return set.copyWith(isCompleted: true);
    }).toList();

    emit(currentState.copyWith(isFinishMode: true, sets: updatedSets));
  }

  /// Tắt chế độ kết thúc - Bỏ đánh dấu tất cả các set
  void disableFinishMode() {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) return;

    // ✅ Bỏ đánh dấu tất cả các set
    final updatedSets = currentState.sets.map((set) {
      return set.copyWith(isCompleted: false);
    }).toList();

    emit(currentState.copyWith(isFinishMode: false, sets: updatedSets));
  }

  /// Kết thúc workout và lưu vào history (private method)
  Future<void> _finishWorkout() async {
    final saved = await saveWorkoutSession();
    if (saved) {
      stopWorkoutSession();
    }
  }

  /// Lưu workout session vào Supabase (public để gọi từ UI)
  Future<bool> saveWorkoutSession() async {
    final currentState = state;
    if (currentState is! ExerciseSessionActive) {
      print('❌ ERROR: State is not ExerciseSessionActive');
      return false;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ ERROR: User is not authenticated');
        return false;
      }

      print('✅ User ID: $userId');

      // ✅ Lưu progress cho TỪNG exercise
      await _saveWorkoutProgress(currentState, userId);

      // Tính toán thống kê cho TẤT CẢ exercises
      int totalSets = 0;
      int completedSets = 0;
      int completedExercises = 0;
      final exerciseDetails = <ExerciseSessionDetail>[];

      for (int i = 0; i < currentState.exercises.length; i++) {
        final exercise = currentState.exercises[i];

        List<WorkoutSet> sets;
        if (i == currentState.currentExerciseIndex) {
          sets = currentState.sets;
        } else if (i < currentState.currentExerciseIndex) {
          sets = List.generate(
            4,
            (index) => WorkoutSet(
              setNumber: index + 1,
              weight: 8.0,
              reps: 8,
              isCompleted: true,
            ),
          );
        } else {
          sets = List.generate(
            4,
            (index) => WorkoutSet(
              setNumber: index + 1,
              weight: 8.0,
              reps: 8,
              isCompleted: false,
            ),
          );
        }

        final setDetails = sets
            .map(
              (set) => SetDetail(
                setNumber: set.setNumber,
                weight: set.weight,
                reps: set.reps,
                isCompleted: set.isCompleted,
              ),
            )
            .toList();

        totalSets += setDetails.length;
        completedSets += setDetails.where((s) => s.isCompleted).length;

        if (setDetails.isNotEmpty && setDetails.every((s) => s.isCompleted)) {
          completedExercises++;
        }

        exerciseDetails.add(
          ExerciseSessionDetail(
            exerciseId: exercise.id,
            exerciseName: exercise.title,
            sets: setDetails,
          ),
        );
      }

      // ✅ FIX: BỎ category_name, CHỈ GỬI category_id
      final sessionData = {
        'for_user': userId,
        'category_id': currentState.categoryId, // ✅ CHỈ GỬI ID
        // ❌ BỎ: 'category_name': currentState.categoryName,
        'total_exercises': currentState.exercises.length,
        'completed_exercises': completedExercises,
        'total_sets': totalSets,
        'completed_sets': completedSets,
        'duration_seconds': currentState.elapsedSeconds,
        'exercise_details': exerciseDetails.map((e) => e.toJson()).toList(),
      };

      print('📦 Session data to save:');
      print(sessionData);

      final response = await _supabase
          .from('history_workout')
          .insert(sessionData)
          .select();

      print('✅ Insert successful: $response');
      return true;
    } catch (e, stackTrace) {
      print('❌ ERROR saving workout session:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  /// ✅ Lưu progress cho từng exercise
  Future<void> _saveWorkoutProgress(
    ExerciseSessionActive state,
    String userId,
  ) async {
    try {
      for (int i = 0; i < state.exercises.length; i++) {
        final exercise = state.exercises[i];

        int completedSets;
        int totalSets;

        if (i < state.currentExerciseIndex) {
          // ✅ Bài đã hoàn thành trước đó - LẤY từ history hoặc mặc định 4
          completedSets = 4;
          totalSets = 4;
        } else if (i == state.currentExerciseIndex) {
          // ✅ Bài đang làm - LẤY số sets thực tế từ state
          completedSets = state.completedSetsCount;
          totalSets = state.sets.length; // ✅ FIX: Số sets THỰC TẾ user đã thêm
        } else {
          // Bài chưa làm
          completedSets = 0;
          totalSets = 4;
        }

        final progress = WorkoutProgress(
          forUser: userId,
          categoryId: state.categoryId,
          exerciseId: exercise.id,
          completedSets: completedSets,
          totalSets: totalSets, // ✅ LƯU đúng số sets
          isFullyCompleted: completedSets == totalSets,
        );

        // ✅ Debug log
        print('💾 Saving progress for ${exercise.title}:');
        print('   Completed: $completedSets/$totalSets sets');

        await _supabase
            .from('workout_progress')
            .upsert(
              progress.toJson(),
              onConflict: 'for_user,for_category,for_exercise',
            );
      }
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  /// ✅ Load progress cho category
  Future<Map<String, WorkoutProgress>> loadProgress(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      // ✅ FIX: Dùng 'for_category' thay vì 'category_id'
      final response = await _supabase
          .from('workout_progress')
          .select()
          .eq('for_user', userId)
          .eq(
            'for_category',
            categoryId,
          ); // ✅ Đổi từ 'category_id' → 'for_category'

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

  /// ✅ Reset progress cho category
  Future<void> resetProgress(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ FIX: Dùng 'for_category' thay vì 'category_id'
      await _supabase
          .from('workout_progress')
          .delete()
          .eq('for_user', userId)
          .eq(
            'for_category',
            categoryId,
          ); // ✅ Đổi từ 'category_id' → 'for_category'
    } catch (e) {
      print('❌ Error resetting progress: $e');
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
        final keyLower = device.name.toLowerCase();
        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = device;
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

  /// ✅ Load danh sách upcoming workouts từ scheduled_workouts table
  Future<List<UpcomingWorkout>> loadUpcomingWorkouts({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedUpcomingWorkouts != null) {
      return _cachedUpcomingWorkouts!;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final now = DateTime.now();

      // ✅ FIX: Lọc is_completed = false VÀ scheduled_time >= now
      final response = await _supabase
          .from('scheduled_workouts')
          .select()
          .eq('for_user', userId)
          .eq('is_completed', false) // ✅ Chỉ lấy chưa hoàn thành
          .gte('scheduled_time', now.toIso8601String()) // ✅ Trong tương lai
          .order('scheduled_time')
          .limit(3);

      print('📅 Scheduled workouts: ${response.length} records');

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

      _cachedUpcomingWorkouts = upcomingList;
      return upcomingList;
    } catch (e) {
      print('❌ Error loading upcoming workouts: $e');
      return [];
    }
  }

  /// ✅ Load workout stats cho biểu đồ (7 ngày gần nhất)
  Future<List<double>> loadWeeklyWorkoutStats({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedWeeklyStats != null) {
      return _cachedWeeklyStats!;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return List.filled(7, 0.0);

      final now = DateTime.now();

      // ✅ FIX: Lấy từ đầu tuần (Chủ nhật = 0)
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day - now.weekday % 7,
      );

      print('📊 Loading stats from: $startOfWeek to $now');

      final response = await _supabase
          .from('history_workout')
          .select('created_at, completed_exercises, total_exercises')
          .eq('for_user', userId)
          .gte('created_at', startOfWeek.toIso8601String())
          .lte('created_at', now.toIso8601String())
          .order('created_at');

      print('📦 Found ${response.length} workout records');

      final stats = List<double>.filled(7, 0.0);
      final counts = List<int>.filled(7, 0);

      for (var record in response) {
        final createdAt = DateTime.parse(record['created_at']);
        final dayIndex = createdAt.weekday % 7; // 0 = Sunday, 1 = Monday, ...

        final completed = (record['completed_exercises'] ?? 0) as int;
        final total = (record['total_exercises'] ?? 1) as int;

        // ✅ FIX: Tính % chính xác
        final percent = total > 0 ? (completed / total) * 100 : 0.0;

        print(
          '   Day $dayIndex: $completed/$total = ${percent.toStringAsFixed(1)}%',
        );

        stats[dayIndex] += percent;
        counts[dayIndex]++;
      }

      // ✅ Tính trung bình nếu có nhiều workout trong 1 ngày
      for (int i = 0; i < 7; i++) {
        if (counts[i] > 0) {
          stats[i] = (stats[i] / counts[i]).clamp(0.0, 100.0);
          print(
            '✅ Day $i final: ${stats[i].toStringAsFixed(1)}% (${counts[i]} workouts)',
          );
        }
      }

      // ✅ Lưu vào cache
      _cachedWeeklyStats = stats;
      return stats;
    } catch (e) {
      print('❌ Error loading weekly stats: $e');
      return List.filled(7, 0.0);
    }
  }

  // ============ ✅ Exercise Item Expansion Methods ============

  /// Toggle expand/collapse cho một exercise item cụ thể
  void toggleExerciseItemExpansion(String exerciseId) {
    final currentState = _exerciseItemExpandedStates[exerciseId] ?? false;
    _exerciseItemExpandedStates[exerciseId] = !currentState;
    emit(ExerciseItemExpanded(exerciseId, !currentState));
  }

  /// Get trạng thái expand của exercise item
  bool isExerciseItemExpanded(String exerciseId) {
    return _exerciseItemExpandedStates[exerciseId] ?? false;
  }

  /// Expand exercise item
  void expandExerciseItem(String exerciseId) {
    _exerciseItemExpandedStates[exerciseId] = true;
    emit(ExerciseItemExpanded(exerciseId, true));
  }

  /// Collapse exercise item
  void collapseExerciseItem(String exerciseId) {
    _exerciseItemExpandedStates[exerciseId] = false;
    emit(ExerciseItemExpanded(exerciseId, false));
  }

  // ✅ Public getter for cache (để workout_tracker_view có thể access)
  List<UpcomingWorkout>? get cachedUpcomingWorkouts => _cachedUpcomingWorkouts;
  List<double>? get cachedWeeklyStats => _cachedWeeklyStats;
}
