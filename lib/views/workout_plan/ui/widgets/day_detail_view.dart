import 'dart:async'; // ✅ Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_plan/logic/cubit/workout_plan_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_list_tiles.dart';
import 'meal_session_group.dart';

/// Widget chi tiết của một ngày trong workout plan với Start button và Timer
class DayDetailView extends StatefulWidget {
  final DailyPlan day;
  final DayPlanProgress? progress;

  const DayDetailView({super.key, required this.day, this.progress});

  @override
  State<DayDetailView> createState() => _DayDetailViewState();
}

class _DayDetailViewState extends State<DayDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isWorkoutActive = false;
  int? _dailyCalorieTarget; // Nullable, load from meal planner
  Timer? _refreshTimer; // ✅ Add auto-refresh timer

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCalorieTarget();

    // ✅ Auto-refresh calories every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadCalorieTarget();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Reload when widget is displayed
    _loadCalorieTarget();
  }

  @override
  void didUpdateWidget(DayDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh calorie target khi user quay lại từ meal planner
    _loadCalorieTarget();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel(); // ✅ Cancel timer
    super.dispose();
  }

  /// Load daily calorie target từ meal planner preferences
  Future<void> _loadCalorieTarget() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Load trực tiếp từ user_activity_preferences giống daily_activity_section
      final preferencesResponse = await Supabase.instance.client
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (preferencesResponse != null &&
              preferencesResponse['daily_calorie_target'] != null) {
            _dailyCalorieTarget =
                preferencesResponse['daily_calorie_target'] as int;
          } else {
            _dailyCalorieTarget = null;
          }
        });
      }

      debugPrint(
        '🍽️ Calorie target loaded in day_detail_view: $_dailyCalorieTarget',
      );
    } catch (e) {
      debugPrint('❌ Error loading calorie target: $e');
      if (mounted) {
        setState(() => _dailyCalorieTarget = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.progress?.isCompleted ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, isCompleted),
          _buildTabBar(),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primaryColor1, TColor.primaryColor2],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Day info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${LocaleKey.dayNumber.tr} ${widget.day.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.day.dayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Completed badge
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        LocaleKey.completed.tr,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.fitness_center,
                  '${widget.day.workouts.length}',
                  LocaleKey.exercises.tr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.restaurant,
                  '${widget.day.meals.length}',
                  LocaleKey.meals.tr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  Icons.local_fire_department,
                  '${_getTotalCalories().toStringAsFixed(0)}/${_dailyCalorieTarget}',
                  LocaleKey.calories.tr,
                ),
              ),
            ],
          ),

          // Calorie progress bar
          const SizedBox(height: 12),
          _buildCalorieProgressBar(),

          if (!isCompleted) ...[
            const SizedBox(height: 16),
            _buildStartButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build calorie progress bar
  Widget _buildCalorieProgressBar() {
    final totalCalories = _getTotalCalories();
    final progress = (_dailyCalorieTarget != null && _dailyCalorieTarget! > 0)
        ? (totalCalories / _dailyCalorieTarget!).clamp(0.0, 1.0)
        : 0.0;
    final isOverLimit =
        _dailyCalorieTarget != null && totalCalories > _dailyCalorieTarget!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKey.dailyCalorieTarget.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _dailyCalorieTarget == null
                    ? '${totalCalories.toStringAsFixed(0)} / ...'
                    : '${totalCalories.toStringAsFixed(0)} / $_dailyCalorieTarget',
                style: TextStyle(
                  color: isOverLimit ? Colors.red[300] : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                isOverLimit ? Colors.red[300]! : Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state is WorkoutStarted || state is WorkoutTimerTick) {
          final elapsedSeconds = context
              .read<WorkoutPlanCubit>()
              .elapsedSeconds;
          return _buildWorkoutControls(context, elapsedSeconds, false);
        } else if (state is WorkoutPaused) {
          return _buildWorkoutControls(context, state.elapsedSeconds, true);
        }

        return ElevatedButton(
          onPressed: () {
            context.read<WorkoutPlanCubit>().startWorkout(widget.day.dayNumber);
            setState(() => _isWorkoutActive = true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: TColor.primaryColor1,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 24),
              const SizedBox(width: 8),
              Text(
                LocaleKey.startWorkout.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutControls(
    BuildContext context,
    int elapsedSeconds,
    bool isPaused,
  ) {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Timer display
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: TColor.primaryColor1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),

          // Control buttons
          Row(
            children: [
              // Pause/Resume button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isPaused) {
                      context.read<WorkoutPlanCubit>().resumeWorkout();
                    } else {
                      context.read<WorkoutPlanCubit>().pauseWorkout();
                    }
                  },
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(
                    isPaused ? LocaleKey.resume.tr : LocaleKey.pause.tr,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Complete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteDialog(context),
                  icon: const Icon(Icons.check),
                  label: Text(LocaleKey.complete.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            onPressed: () {
              context.read<WorkoutPlanCubit>().cancelWorkout();
              setState(() => _isWorkoutActive = false);
            },
            child: Text(
              LocaleKey.cancel.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKey.completeWorkout.tr),
        content: Text(LocaleKey.confirmCompleteWorkout.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LocaleKey.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutPlanCubit>().completeWorkout();
              setState(() => _isWorkoutActive = false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(LocaleKey.complete.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: TColor.primaryColor1,
        unselectedLabelColor: TColor.gray,
        indicatorColor: TColor.primaryColor1,
        tabs: [
          Tab(
            icon: Icon(Icons.fitness_center, size: 20),
            text: LocaleKey.workouts.tr,
          ),
          Tab(icon: Icon(Icons.restaurant, size: 20), text: LocaleKey.meals.tr),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [_buildWorkoutList(), _buildMealList()],
      ),
    );
  }

  Widget _buildWorkoutList() {
    if (widget.day.workouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: TColor.gray),
              const SizedBox(height: 16),
              Text(
                LocaleKey.noWorkouts.tr,
                style: TextStyle(color: TColor.secondaryColor1),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.day.workouts.length,
      itemBuilder: (context, index) {
        return WorkoutSessionListTile(workout: widget.day.workouts[index]);
      },
    );
  }

  Widget _buildMealList() {
    if (widget.day.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: TColor.gray),
              const SizedBox(height: 16),
              Text(
                LocaleKey.noMeals.tr,
                style: TextStyle(color: TColor.secondaryColor1),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MealSessionGroup(meals: widget.day.meals),
    );
  }

  /// Tính tổng calories của tất cả bữa ăn trong ngày
  double _getTotalCalories() {
    return widget.day.meals.fold(
      0.0,
      (total, meal) => total + meal.totalCalories,
    );
  }
}
