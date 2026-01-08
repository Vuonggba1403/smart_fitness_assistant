import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_showdialog.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_plan/logic/cubit/workout_plan_cubit.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/views/multi_step_dialog_workout/ui/multi_step_plan_dialog.dart';
import 'widgets/calendar_week_view.dart';
import 'widgets/workout_plan_completion_screen.dart';

/// Main view cho Workout Plan
class WorkoutPlanView extends StatefulWidget {
  const WorkoutPlanView({super.key});

  @override
  State<WorkoutPlanView> createState() => _WorkoutPlanViewState();
}

class _WorkoutPlanViewState extends State<WorkoutPlanView> {
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();
    final userId = authCubit.userDataModel?.userId ?? "";

    return BlocProvider(
      create: (context) {
        final cubit = WorkoutPlanCubit();
        cubit.initialize(userId);
        return cubit;
      },
      child: const _WorkoutPlanContent(),
    );
  }
}

/// Nội dung chính của workout plan view
class _WorkoutPlanContent extends StatefulWidget {
  const _WorkoutPlanContent();

  @override
  State<_WorkoutPlanContent> createState() => _WorkoutPlanContentState();
}

class _WorkoutPlanContentState extends State<_WorkoutPlanContent> {
  int? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload plan khi quay lại màn hình (để cập nhật calorie target)
    final cubit = context.read<WorkoutPlanCubit>();
    final authCubit = context.read<AuthenticationCubit>();
    final userId = authCubit.userDataModel?.userId ?? "";
    if (userId.isNotEmpty && cubit.currentPlan != null) {
      // Just trigger a rebuild, calorie target will be reloaded in DayDetailView
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.workoutPlanTitle.tr),
      body: BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
        listener: (context, state) {
          // Handle plan completion
          if (state is WorkoutPlanCompleted) {
            _showCompletionScreen(context, state);
          }
          // Handle day completion
          else if (state is WorkoutDayCompleted) {
            _showDayCompletedSnackBar(context, state);
          }
        },
        builder: (context, state) {
          // Get current plan from cubit (không phụ thuộc vào state)
          final cubit = context.read<WorkoutPlanCubit>();
          final currentPlan = cubit.currentPlan;

          if (state is WorkoutPlanLoading) {
            return _buildLoadingState(state.message);
          }

          // Hiển thị plan nếu có (bất kể state là gì - Loaded, WorkoutStarted, etc.)
          if (currentPlan != null) {
            return _buildPlanView(context, currentPlan);
          }

          if (state is WorkoutPlanError) {
            return _buildErrorState(context, state.message);
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  void _showCompletionScreen(BuildContext context, WorkoutPlanCompleted state) {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        navigateTo(
          context,
          WorkoutPlanCompletionScreen(progress: state.progress),
        );
      }
    });
  }

  void _showDayCompletedSnackBar(
    BuildContext context,
    WorkoutDayCompleted state,
  ) {
    final minutes = (state.durationSeconds ~/ 60);
    final seconds = (state.durationSeconds % 60);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${LocaleKey.dayNumber.tr} ${state.dayNumber} ${LocaleKey.completed.tr}! '
          '⏱️ $minutes:${seconds.toString().padLeft(2, '0')}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showGeneratePlanDialog(context),
            child: Text(LocaleKey.retry.tr),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            LocaleKey.noWorkoutPlan.tr,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showGeneratePlanDialog(context),
            icon: const Icon(Icons.auto_awesome),
            label: Text(LocaleKey.createPlanWithAI.tr),
          ),
        ],
      ),
    );
  }

  /// Build plan view với calendar
  Widget _buildPlanView(BuildContext context, WorkoutPlan plan) {
    final cubit = context.read<WorkoutPlanCubit>();
    final progress = cubit.currentProgress;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header với delete button
          _buildPlanHeader(context),

          // Calendar grid view
          CalendarWeekView(
            plan: plan,
            progress: progress,
            selectedDay: _selectedDay,
            onDaySelected: (dayNumber) {
              setState(() {
                _selectedDay = dayNumber;
              });
            },
          ),

          // Progress overview
          if (progress != null) _buildProgressOverview(progress),

          // Workout history
          if (progress != null) _buildWorkoutHistory(plan, progress),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKey.thirtyDayPlan.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColor.primaryColor1,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              AppConfirmDialog.show(
                context: context,
                title: LocaleKey.confirmDeletePlan.tr,
                content: LocaleKey.confirmDeletePlanMessage.tr,
                onYes: () {
                  context.read<WorkoutPlanCubit>().deletePlan();
                },
              );
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(LocaleKey.deletePlan.tr),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(WorkoutPlanProgress progress) {
    final completedDays = progress.completedDaysCount;
    final totalDays = progress.dayProgressList.length;
    final progressPercent = progress.overallProgress;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primaryColor1, TColor.primaryColor2],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKey.overallProgress.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedDays/$totalDays ${LocaleKey.days.tr}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistory(WorkoutPlan plan, WorkoutPlanProgress progress) {
    final completedDays = progress.dayProgressList
        .where((day) => day.isCompleted)
        .toList();

    if (completedDays.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColor.gray.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: TColor.gray),
              const SizedBox(height: 12),
              Text(
                LocaleKey.noHistoryYet.tr,
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: TColor.primaryColor1, size: 24),
                const SizedBox(width: 8),
                Text(
                  LocaleKey.workoutHistory.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryColor1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedDays.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: TColor.gray.withOpacity(0.2)),
            itemBuilder: (context, index) {
              final dayProgress = completedDays[index];
              final dayPlan = plan.dailyPlans.firstWhere(
                (d) => d.dayNumber == dayProgress.dayNumber,
              );

              // Tính tổng calories từ meals
              final totalCalories = dayPlan.meals.fold<double>(
                0.0,
                (sum, meal) => sum + meal.totalCalories,
              );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Day number badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [TColor.primaryColor1, TColor.primaryColor2],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${dayProgress.dayNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayPlan.dayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: TColor.secondaryColor1,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${((dayProgress.workoutDurationSeconds ?? 0) / 60).toStringAsFixed(0)} ${LocaleKey.minutes.tr}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TColor.secondaryColor1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${totalCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Check icon
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog tạo plan
  void _showGeneratePlanDialog(BuildContext context) async {
    final cubit = context.read<WorkoutPlanCubit>();
    final authCubit = context.read<AuthenticationCubit>();
    final user = authCubit.userDataModel;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKey.pleaseLogin.tr)));
      return;
    }

    await cubit.loadActivityLevels();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
          builder: (context, state) {
            if (state is ActivityLevelsLoading) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(LocaleKey.loading.tr),
                  ],
                ),
              );
            }

            if (state is ActivityLevelsLoaded) {
              return MultiStepPlanDialog(
                activityLevels: state.levels,
                onComplete: (activityLevel, fitnessProfile) async {
                  Navigator.pop(dialogContext);
                  await cubit.generatePlan(
                    user: user,
                    activityLevel: activityLevel,
                    fitnessProfile: fitnessProfile,
                  );
                },
              );
            }

            return AlertDialog(
              title: Text(LocaleKey.error.tr),
              content: Text(LocaleKey.cannotLoadData.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(LocaleKey.close.tr),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
