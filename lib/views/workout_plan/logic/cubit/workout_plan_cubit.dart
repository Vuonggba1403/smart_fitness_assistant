import 'dart:developer';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_plan/data/workout_plan_repository.dart';
import 'package:smart_fitness_assistant/core/services/streak_service.dart';

part 'workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanRepository _repository = WorkoutPlanRepository();
  WorkoutPlan? _currentPlan;
  WorkoutPlanProgress? _currentProgress;
  String? _userId;

  // Timer cho workout session
  Timer? _workoutTimer;
  int _currentDayNumber = 0;
  int _elapsedSeconds = 0;

  WorkoutPlanCubit() : super(WorkoutPlanInitial());

  /// ✅ Initialize với userId và auto-load saved plan
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadSavedPlan();
    await loadProgress();
  }

  /// ✅ Load workout plan progress từ SharedPreferences
  Future<void> loadProgress() async {
    if (_userId == null || _currentPlan == null) return;

    try {
      final progressJson = await AppShared.getWorkoutPlanProgress(_userId!);

      if (progressJson != null && progressJson['plan_id'] == _currentPlan!.id) {
        _currentProgress = WorkoutPlanProgress.fromJson(progressJson);
        log('✅ Loaded workout plan progress');

        // Emit state để UI cập nhật
        if (state is WorkoutPlanLoaded) {
          emit(WorkoutPlanLoaded(_currentPlan!));
        }
      } else {
        // Tạo progress mới nếu chưa có hoặc plan ID không khớp
        await _initializeProgress();
      }
    } catch (e) {
      log('❌ Error loading progress: $e');
      await _initializeProgress();
    }
  }

  /// Khởi tạo progress mới cho plan hiện tại
  Future<void> _initializeProgress() async {
    if (_currentPlan == null || _userId == null) return;

    // Đếm số exercises trong mỗi ngày
    final dayExerciseCounts = <int, int>{};
    for (var day in _currentPlan!.dailyPlans) {
      dayExerciseCounts[day.dayNumber] = day.workouts.length;
    }

    _currentProgress = WorkoutPlanProgress.initial(
      planId: _currentPlan!.id,
      userId: _userId!,
      totalDays: _currentPlan!.dailyPlans.length,
      dayExerciseCounts: dayExerciseCounts,
    );

    await _saveProgress();
    log('✅ Initialized new progress for plan: ${_currentPlan!.id}');
  }

  /// ✅ Load workout plan đã lưu từ SharedPreferences
  Future<void> loadSavedPlan() async {
    if (_userId == null) return;

    try {
      final savedPlanJson = await AppShared.getWorkoutPlan(_userId!);

      if (savedPlanJson != null) {
        _currentPlan = WorkoutPlan.fromFullJson(savedPlanJson);

        // ✅ Check if plan is expired (older than 7 days)
        if (_isPlanExpired(_currentPlan!)) {
          log('⏰ Plan expired, prompting user to create new plan');
          await deletePlan();
          emit(
            WorkoutPlanExpired(
              'Kế hoạch đã hết hạn. Vui lòng tạo kế hoạch mới.',
            ),
          );
          return;
        }

        emit(WorkoutPlanLoaded(_currentPlan!));
        log('✅ Loaded saved workout plan for user: $_userId');
      } else {
        emit(WorkoutPlanInitial());
      }
    } catch (e) {
      log('❌ Error loading saved plan: $e');
      emit(WorkoutPlanInitial());
    }
  }

  /// ✅ Check if plan is expired (older than 7 days)
  bool _isPlanExpired(WorkoutPlan plan) {
    final daysSinceCreated = DateTime.now().difference(plan.createdAt).inDays;
    return daysSinceCreated >= 7;
  }

  /// ✅ Check current plan status (call from UI when needed)
  void checkPlanStatus() {
    if (_currentPlan != null && _isPlanExpired(_currentPlan!)) {
      deletePlan();
      emit(
        WorkoutPlanExpired('Kế hoạch đã hết hạn. Vui lòng tạo kế hoạch mới.'),
      );
    }
  }

  /// Load activity levels
  Future<void> loadActivityLevels() async {
    emit(ActivityLevelsLoading());
    try {
      final levels = await _repository.fetchActivityLevels();
      emit(ActivityLevelsLoaded(levels));
    } catch (e) {
      log('❌ Error loading activity levels: $e');
      emit(WorkoutPlanError('Không thể tải mức độ hoạt động'));
    }
  }

  /// Generate workout plan
  Future<void> generatePlan({
    required UserDataModel user,
    required ActivityLevel activityLevel,
    required UserFitnessProfile fitnessProfile, // ✅ Thêm parameter
  }) async {
    emit(WorkoutPlanLoading(LocaleKey.loadingData.tr));

    try {
      // ✅ Load daily calorie target from meal planner preferences
      int? dailyCalorieTarget;
      try {
        dailyCalorieTarget = await AppShared.getDailyCalorieTarget(user.userId);
        if (dailyCalorieTarget != null && dailyCalorieTarget > 0) {
          log(
            '🍽️ Daily calorie target from Meal Planner: $dailyCalorieTarget kcal',
          );
        } else {
          log(
            '⚠️ No calorie target set, AI will calculate based on user goals',
          );
        }
      } catch (e) {
        log('⚠️ Could not load calorie target: $e');
        dailyCalorieTarget = null;
      }

      // Fetch exercises và meals
      emit(WorkoutPlanLoading(LocaleKey.loadingExercises.tr));
      final exercises = await _repository.fetchExercises();
      final meals = await _repository.fetchMeals();

      log('📊 Fetched ${exercises.length} exercises and ${meals.length} meals');

      // Validate meals count
      if (meals.length < 30) {
        log(
          '⚠️ Warning: Only ${meals.length} meals available, need at least 30 for variety',
        );
      }

      log(
        '🍽️ Meals sample: ${meals.take(3).map((m) => m.name).join(", ")}...',
      );

      // Generate plan với AI
      emit(WorkoutPlanLoading('AI đang tạo kế hoạch cho bạn...'));
      final plan = await _repository.generatePlan(
        user: user,
        activityLevel: activityLevel,
        fitnessProfile: fitnessProfile, // ✅ Pass fitness profile
        exercises: exercises,
        meals: meals,
        dailyCalorieTarget: dailyCalorieTarget, // ✅ Pass calorie target
      );

      _currentPlan = plan;

      // Debug: Log meal count per day
      int totalMeals = 0;
      int daysWithoutMeals = 0;
      for (var day in plan.dailyPlans) {
        totalMeals += day.meals.length;
        if (day.meals.isEmpty) {
          daysWithoutMeals++;
          log('❌ Day ${day.dayNumber} has NO MEALS!');
        }
        log(
          '📅 Day ${day.dayNumber}: ${day.workouts.length} workouts, ${day.meals.length} meals',
        );
      }

      log(
        '🍽️ Total meals generated: $totalMeals, Days without meals: $daysWithoutMeals',
      );

      if (daysWithoutMeals > 0) {
        log('⚠️ WARNING: $daysWithoutMeals days are missing meals!');
      }

      // ✅ Initialize progress for new plan
      final dayExerciseCounts = <int, int>{};
      for (var day in plan.dailyPlans) {
        // Mỗi WorkoutSession = 1 exercise
        dayExerciseCounts[day.dayNumber] = day.workouts.length;
      }

      _currentProgress = WorkoutPlanProgress.initial(
        planId: plan.id,
        userId: user.userId,
        totalDays: plan.dailyPlans.length,
        dayExerciseCounts: dayExerciseCounts,
      );
      await _saveProgress();
      log('📊 Initial progress created for ${plan.dailyPlans.length} days');

      // ✅ Auto save plan sau khi generate
      await _savePlan(user.userId);

      emit(WorkoutPlanLoaded(plan));
      log('✅ Workout plan generated and saved successfully');
    } catch (e) {
      log('❌ Error generating plan: $e');
      emit(WorkoutPlanError('Không thể tạo kế hoạch. Vui lòng thử lại.'));
    }
  }

  /// ✅ Lưu plan vào SharedPreferences
  Future<void> _savePlan(String userId) async {
    if (_currentPlan == null) return;

    try {
      final planJson = _currentPlan!.toFullJson();
      await AppShared.saveWorkoutPlan(userId, planJson);
      log('💾 Workout plan saved to local storage');

      // Optional: Sync to cloud
      // await AppShared.saveWorkoutPlanToCloud(userId, planJson);
    } catch (e) {
      log('❌ Error saving plan: $e');
    }
  }

  /// ✅ Xóa workout plan
  Future<void> deletePlan() async {
    if (_userId == null) return;

    try {
      await AppShared.deleteWorkoutPlan(_userId!);
      _currentPlan = null;
      emit(WorkoutPlanInitial());
      log('🗑️ Workout plan deleted');
    } catch (e) {
      log('❌ Error deleting plan: $e');
      emit(WorkoutPlanError('Không thể xóa kế hoạch'));
    }
  }

  /// Get current plan
  WorkoutPlan? get currentPlan => _currentPlan;

  /// Get current progress
  WorkoutPlanProgress? get currentProgress => _currentProgress;

  /// Get elapsed seconds for current workout
  int get elapsedSeconds => _elapsedSeconds;

  /// Lưu progress vào SharedPreferences
  Future<void> _saveProgress() async {
    if (_currentProgress == null || _userId == null) return;

    try {
      await AppShared.saveWorkoutPlanProgress(
        _userId!,
        _currentProgress!.toJson(),
      );
      log('💾 Progress saved');
    } catch (e) {
      log('❌ Error saving progress: $e');
    }
  }

  /// Bắt đầu workout cho một ngày cụ thể
  void startWorkout(int dayNumber) {
    if (_currentPlan == null || _currentProgress == null) return;

    _currentDayNumber = dayNumber;
    _elapsedSeconds = 0;

    // Bắt đầu timer
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      emit(WorkoutTimerTick(_elapsedSeconds));
    });

    emit(WorkoutStarted(dayNumber));
    log('🏃 Started workout for day $dayNumber');
  }

  /// Tạm dừng workout
  void pauseWorkout() {
    _workoutTimer?.cancel();
    emit(WorkoutPaused(_currentDayNumber, _elapsedSeconds));
    log('⏸️ Workout paused');
  }

  /// Tiếp tục workout
  void resumeWorkout() {
    if (_currentDayNumber == 0) return;

    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      emit(WorkoutTimerTick(_elapsedSeconds));
    });

    emit(WorkoutResumed(_currentDayNumber, _elapsedSeconds));
    log('▶️ Workout resumed');
  }

  /// Hoàn thành workout cho ngày hiện tại
  Future<void> completeWorkout() async {
    if (_currentDayNumber == 0 || _currentProgress == null) return;

    _workoutTimer?.cancel();

    // Lấy số exercise trong ngày
    final dayPlan = _currentPlan?.dailyPlans.firstWhere(
      (d) => d.dayNumber == _currentDayNumber,
    );
    final totalExercises = dayPlan?.workouts.length ?? 0;

    // Update progress
    final dayProgress = _currentProgress!.getProgressForDay(_currentDayNumber);
    if (dayProgress != null) {
      final updatedDayProgress = dayProgress.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        workoutDurationSeconds: _elapsedSeconds,
        completedExercises: totalExercises,
      );

      _currentProgress = _currentProgress!.updateDayProgress(
        updatedDayProgress,
      );
      await _saveProgress();

      // ✅ STREAK: Record workout completion
      await _recordWorkoutStreak(totalExercises, _elapsedSeconds);

      // Kiểm tra xem đã hoàn thành toàn bộ plan chưa
      if (_currentProgress!.isPlanCompleted) {
        emit(WorkoutPlanCompleted(_currentProgress!));
        log('🎉 Workout plan completed!');

        // Mint NFT badge sau khi hoàn thành plan (sẽ được xử lý ở UI)
      } else {
        emit(WorkoutDayCompleted(_currentDayNumber, _elapsedSeconds));
        log('✅ Day $_currentDayNumber completed in $_elapsedSeconds seconds');
      }
    }

    // Reset timer
    _elapsedSeconds = 0;
    _currentDayNumber = 0;
  }

  /// Record workout in streak system
  Future<void> _recordWorkoutStreak(int exercises, int durationSeconds) async {
    try {
      if (_userId == null) return;

      final streakService = StreakService();
      final result = await streakService.recordWorkout(
        _userId!,
        exercisesCompleted: exercises,
        durationMinutes: (durationSeconds / 60).round(),
        caloriesBurned: ((durationSeconds / 60) * 5)
            .round(), // Estimate: 5 cal/min
      );

      if (result.success) {
        log('🔥 Streak updated: ${result.currentStreak} days');

        // Show milestone achievement
        if (result.achievedMilestone != null) {
          log('🎯 MILESTONE: ${result.achievedMilestone!.name}');
          // Will trigger NFT minting in UI
        }
      }
    } catch (e) {
      log('❌ Error recording streak: $e');
    }
  }

  /// Hủy workout hiện tại
  void cancelWorkout() {
    _workoutTimer?.cancel();
    _elapsedSeconds = 0;
    _currentDayNumber = 0;

    if (_currentPlan != null) {
      emit(WorkoutPlanLoaded(_currentPlan!));
    }

    log('❌ Workout cancelled');
  }

  @override
  Future<void> close() {
    _workoutTimer?.cancel();
    return super.close();
  }
}
