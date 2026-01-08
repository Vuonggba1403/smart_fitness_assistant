import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_plan/logic/cubit/workout_plan_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/session_list_tiles.dart';
import 'widgets/meal_session_group.dart';

/// Trang chi tiết của một ngày trong workout plan
class DayDetailPage extends StatefulWidget {
  final DailyPlan day;
  final DayPlanProgress? progress;

  const DayDetailPage({super.key, required this.day, this.progress});

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _dailyCalorieTarget;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCalorieTarget();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCalorieTarget() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      // Lấy calorie target từ meal planner preferences
      final target = await AppShared.getDailyCalorieTarget(userId);
      if (mounted) {
        setState(() => _dailyCalorieTarget = target);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh calorie target khi quay lại trang này
    _loadCalorieTarget();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.progress?.isCompleted ?? false;

    return Scaffold(
      appBar: CustomAppBar(
        title:
            '${LocaleKey.dayNumber.tr} ${widget.day.dayNumber} - ${widget.day.dayName}',
      ),
      body: Column(
        children: [
          // Header with stats
          _buildHeaderSection(isCompleted),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: TColor.primaryColor1,
              unselectedLabelColor: TColor.gray,
              indicatorColor: TColor.primaryColor1,
              tabs: [
                Tab(
                  icon: Icon(Icons.fitness_center),
                  text: LocaleKey.workouts.tr,
                ),
                Tab(icon: Icon(Icons.restaurant), text: LocaleKey.meals.tr),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildWorkoutList(), _buildMealList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primaryColor1, TColor.primaryColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Status badge
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKey.completed.tr,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),

          const SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.fitness_center,
                  '${widget.day.workouts.length}',
                  LocaleKey.exercises.tr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.restaurant,
                  '${widget.day.meals.length}',
                  LocaleKey.meals.tr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.local_fire_department,
                  '${_getTotalCalories().toStringAsFixed(0)}',
                  LocaleKey.calories.tr,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calorie progress
          _buildCalorieProgress(),

          // Action button
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            _buildActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieProgress() {
    final totalCalories = _getTotalCalories();
    final targetCal = _dailyCalorieTarget ?? 0;
    final progress = (targetCal > 0)
        ? (totalCalories / targetCal).clamp(0.0, 1.0)
        : 0.0;
    final isOverLimit = targetCal > 0 && totalCalories > targetCal;

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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _dailyCalorieTarget == null
                    ? '${totalCalories.toStringAsFixed(0)} / ...'
                    : '${totalCalories.toStringAsFixed(0)} / $_dailyCalorieTarget',
                style: TextStyle(
                  color: isOverLimit ? Colors.red[300] : Colors.white,
                  fontSize: 13,
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

  Widget _buildActionButton() {
    return BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state is WorkoutStarted || state is WorkoutTimerTick) {
          final elapsedSeconds = context
              .read<WorkoutPlanCubit>()
              .elapsedSeconds;
          return _buildWorkoutControls(elapsedSeconds, false);
        } else if (state is WorkoutPaused) {
          return _buildWorkoutControls(state.elapsedSeconds, true);
        }

        return ElevatedButton(
          onPressed: () {
            context.read<WorkoutPlanCubit>().startWorkout(widget.day.dayNumber);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: TColor.primaryColor1,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
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

  Widget _buildWorkoutControls(int elapsedSeconds, bool isPaused) {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            timeString,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: TColor.primaryColor1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPaused) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.read<WorkoutPlanCubit>().resumeWorkout(),
                    icon: Icon(Icons.play_arrow),
                    label: Text(LocaleKey.resume.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.read<WorkoutPlanCubit>().pauseWorkout(),
                    icon: Icon(Icons.pause),
                    label: Text(LocaleKey.pause.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<WorkoutPlanCubit>().completeWorkout();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check_circle),
                  label: Text(LocaleKey.complete.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    if (widget.day.workouts.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.day.workouts.length,
      itemBuilder: (context, index) {
        final workout = widget.day.workouts[index];
        return WorkoutSessionListTile(workout: workout);
      },
    );
  }

  Widget _buildMealList() {
    if (widget.day.meals.isEmpty) {
      return Center(
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
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MealSessionGroup(meals: widget.day.meals),
    );
  }

  double _getTotalCalories() {
    return widget.day.meals.fold(
      0.0,
      (total, meal) => total + meal.totalCalories,
    );
  }
}
