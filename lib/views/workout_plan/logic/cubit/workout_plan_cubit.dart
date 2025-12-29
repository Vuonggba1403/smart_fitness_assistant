import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_plan/data/workout_plan_repository.dart';

part 'workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanRepository _repository = WorkoutPlanRepository();
  WorkoutPlan? _currentPlan;
  String? _userId;

  WorkoutPlanCubit() : super(WorkoutPlanInitial());

  /// ✅ Initialize với userId và auto-load saved plan
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadSavedPlan();
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
      // Fetch exercises và meals
      emit(WorkoutPlanLoading(LocaleKey.loadingExercises.tr));
      final exercises = await _repository.fetchExercises();
      final meals = await _repository.fetchMeals();

      // Generate plan với AI
      emit(WorkoutPlanLoading('AI đang tạo kế hoạch cho bạn...'));
      final plan = await _repository.generatePlan(
        user: user,
        activityLevel: activityLevel,
        fitnessProfile: fitnessProfile, // ✅ Pass fitness profile
        exercises: exercises,
        meals: meals,
      );

      _currentPlan = plan;

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
}
