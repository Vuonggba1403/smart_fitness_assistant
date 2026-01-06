import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_showdialog.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_plan/logic/cubit/workout_plan_cubit.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/views/multi_step_dialog_workout/ui/multi_step_plan_dialog.dart';
import 'widgets/session_list_tiles.dart';
import 'widgets/meal_session_group.dart';

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
class _WorkoutPlanContent extends StatelessWidget {
  const _WorkoutPlanContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.workoutPlanTitle.tr),
      body: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
        builder: (context, state) {
          if (state is WorkoutPlanLoading) {
            return _buildLoadingState(state.message);
          }
          if (state is WorkoutPlanLoaded) {
            return _buildPlanView(context, state.plan);
          }
          if (state is WorkoutPlanError) {
            return _buildErrorState(context, state.message);
          }
          return _buildEmptyState(context);
        },
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

  /// Build plan view với tabs
  Widget _buildPlanView(BuildContext context, WorkoutPlan plan) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildTabHeader(context),
          Expanded(
            child: TabBarView(
              children: [_buildWorkoutTab(plan), _buildMealTab(plan)],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab header
  Widget _buildTabHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TabBar(
            labelColor: TColor.primaryColor1,
            unselectedLabelColor: Colors.grey,
            indicatorColor: TColor.primaryColor1,
            tabs: [
              Tab(
                icon: Icon(Icons.fitness_center),
                text: LocaleKey.workoutSchedule.tr,
              ),
              Tab(icon: Icon(Icons.restaurant), text: LocaleKey.eating.tr),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKey.sevenDayPlan.tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build workout tab
  Widget _buildWorkoutTab(WorkoutPlan plan) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plan.dailyPlans.length,
      itemBuilder: (context, index) {
        final day = plan.dailyPlans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inline day header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TColor.primaryColor1, TColor.primaryColor2],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${LocaleKey.dayNumber.tr} ${day.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Workout sessions
              Column(
                children: day.workouts
                    .map((workout) => WorkoutSessionListTile(workout: workout))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build meal tab
  Widget _buildMealTab(WorkoutPlan plan) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plan.dailyPlans.length,
      itemBuilder: (context, index) {
        final day = plan.dailyPlans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inline day header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TColor.primaryColor1, TColor.primaryColor2],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${LocaleKey.dayNumber.tr} ${day.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Meal sessions
              MealSessionGroup(meals: day.meals),
            ],
          ),
        );
      },
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
