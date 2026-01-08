import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/schedule_management/ui/schedule_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_sliverbar.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/workout_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import '../../../locale/locale_key.dart';
import 'widgets/common/upcoming_workout_row.dart';
import 'widgets/common/what_train_row.dart';
import 'widgets/common/workout_chart_config.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:smart_fitness_assistant/views/schedule_management/ui/widgets/time_picker_dialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_section_header.dart';
import 'package:smart_fitness_assistant/views/schedule_management/logic/cubit/schedule_cubit.dart';

/// Main workout tracker screen displaying workout categories and statistics.
///
/// Displays:
/// - Weekly workout completion chart
/// - Upcoming scheduled workouts
/// - Gym exercise categories
/// - Home exercise categories
class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key, required this.title});

  final String title;

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  late Stream<List<UpcomingWorkout>> _upcomingWorkoutsStream;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache is maintained across rebuilds
  }

  /// Initializes notification service and requests permissions.
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// Loads initial data from cache when screen opens.
  void _loadInitialData() {
    final cubit = context.read<WorkoutTrackerCubit>();

    cubit.loadWeeklyWorkoutStats(forceRefresh: false);
    cubit.loadUpcomingWorkouts(forceRefresh: false);
    cubit.loadExerciseCategories(forceRefresh: false);
  }

  /// Refreshes all data from server.
  Future<void> _refreshData() async {
    final cubit = context.read<WorkoutTrackerCubit>();

    await Future.wait([
      cubit.loadWeeklyWorkoutStats(forceRefresh: true),
      cubit.loadUpcomingWorkouts(forceRefresh: true),
      cubit.loadExerciseCategories(forceRefresh: true),
    ]);
  }

  /// Toggles notification on/off for a workout at given index.
  Future<void> _toggleNotification(int index, bool enabled) async {
    final cubit = context.read<WorkoutTrackerCubit>();
    final workouts = cubit.cachedUpcomingWorkouts ?? [];

    if (index >= workouts.length) return;

    final workout = workouts[index];

    if (enabled) {
      await _enableNotification(workout, cubit);
    } else {
      await _disableNotification(workout, cubit);
    }
  }

  /// Enables notification for a workout.
  Future<void> _enableNotification(
    UpcomingWorkout workout,
    WorkoutTrackerCubit cubit,
  ) async {
    final scheduledTime = await WorkoutTimePicker.show(context);
    if (scheduledTime == null) return;

    final now = DateTime.now();
    final minScheduledTime = now.add(const Duration(minutes: 1));

    if (scheduledTime.isBefore(minScheduledTime)) {
      if (mounted) {
        AppSnackBar.error(
          context,
          '${LocaleKey.selectTimeAfter.tr} ${_formatTime(minScheduledTime)}',
        );
      }
      return;
    }

    final success = await cubit.enableWorkoutNotification(
      categoryId: workout.categoryId,
      categoryName: workout.categoryName,
      scheduledTime: scheduledTime,
      scheduleCallback: (id, title, body, time) async {
        await _notificationService.scheduleWorkoutNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: time,
        );
      },
    );

    if (mounted && success) {
      setState(() {});
      AppSnackBar.success(
        context,
        '${LocaleKey.setReminderAt.tr} ${_formatTime(scheduledTime)}',
      );
    }
  }

  /// Disables notification for a workout.
  Future<void> _disableNotification(
    UpcomingWorkout workout,
    WorkoutTrackerCubit cubit,
  ) async {
    final success = await cubit.disableWorkoutNotification(
      categoryId: workout.categoryId,
      cancelCallback: _notificationService.cancelNotification,
    );

    if (mounted && success) {
      AppSnackBar.success(context, LocaleKey.cancelledReminder.tr);
    }
  }

  /// Formats time to HH:mm format.
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Xóa lịch tập đã scheduled - ✅ FIX: Proper state emission
  Future<void> _deleteScheduledWorkout(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Show confirmation dialog trước
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(LocaleKey.confirmDelete.tr),
          content: Text(LocaleKey.confirmDeleteSchedule.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(LocaleKey.cancel.tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                LocaleKey.delete.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      print('🗑️ Deleting workout for category: $categoryId');

      // ✅ Delete from database - Stream sẽ tự động update UI
      final scheduleResponse = await _supabase
          .from('scheduled_workouts')
          .select('id')
          .eq('for_user', userId)
          .eq('category_id', categoryId)
          .single();

      final scheduleId = scheduleResponse['id'] as String;

      final scheduleCubit = context.read<ScheduleCubit>();
      await scheduleCubit.deleteSchedule(scheduleId);

      print(
        '✅ Deleted schedule: $scheduleId - Stream will update UI automatically',
      );

      if (mounted) {
        AppSnackBar.success(context, LocaleKey.deletedSchedule.tr);
      }
    } catch (e) {
      print('❌ Error deleting schedule: $e');

      if (mounted) {
        AppSnackBar.error(context, LocaleKey.cannotDeleteSchedule.tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => WorkoutTrackerCubit()),
        BlocProvider(create: (context) => ScheduleCubit(NotificationService())),
      ],
      child: Builder(
        builder: (context) {
          final cubit = context.read<WorkoutTrackerCubit>();

          _upcomingWorkoutsStream = cubit
              .streamUpcomingWorkouts(); // ✅ Stream cho upcoming workouts

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  CustomSliverAppBar(text: widget.title),
                  _buildChartSection(media, cubit),
                ];
              },
              body: _buildBody(media, theme, textColor, cubit),
            ),
          );
        },
      ),
    );
  }

  /// Builds weekly workout stats chart section.
  Widget _buildChartSection(Size media, WorkoutTrackerCubit cubit) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      leadingWidth: 0,
      leading: const SizedBox(),
      expandedHeight: media.width * 0.5,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: media.width * 0.5,
        width: double.infinity,
        child: BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
          buildWhen: (previous, current) {
            return current is WeeklyStatsUpdated || current is DataRefreshed;
          },
          builder: (context, state) {
            final weeklyStats = cubit.cachedWeeklyStats ?? List.filled(7, 0.0);

            return LineChart(
              LineChartData(
                lineTouchData: WorkoutChartHelper.touchData,
                lineBarsData: weeklyStats.toChartData(),
                minY: -0.5,
                maxY: 110,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: WorkoutChartHelper.bottomTitles,
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: WorkoutChartHelper.rightTitles,
                  ),
                ),
                gridData: WorkoutChartHelper.gridData,
                borderData: FlBorderData(show: false),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds main body content.
  Widget _buildBody(
    Size media,
    ThemeData theme,
    Color? textColor,
    WorkoutTrackerCubit cubit,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildDragHandle(),
              SizedBox(height: media.width * 0.05),
              _buildDailyWorkoutButton(cubit),
              SizedBox(height: media.width * 0.05),
              _buildUpcomingWorkouts(cubit, textColor),
              SizedBox(height: media.width * 0.05),
              _buildGymCategories(textColor, cubit),
              SizedBox(height: media.width * 0.1),
              _buildHomeCategories(textColor, cubit),
              SizedBox(height: media.width * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  /// Build drag handle indicator
  Widget _buildDragHandle() {
    return Container(
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: TColor.gray.withOpacity(0.3),
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
    );
  }

  /// Build nút Daily Workout Schedule - ✅ FIX: Chỉ refresh khi back
  Widget _buildDailyWorkoutButton(WorkoutTrackerCubit cubit) {
    return CustomContainerCheck(
      name: LocaleKey.dailyWorkoutSchedule.tr,
      title: LocaleKey.check.tr,
      onPressed: () async {
        await navigateTo(context, ScheduleView());

        // ✅ FIX: Chỉ refresh khi back từ schedule view
        if (mounted) {
          print('⬅️ Back from ScheduleView - refreshing data');

          await cubit.loadWeeklyWorkoutStats(forceRefresh: true);
          await cubit.loadUpcomingWorkouts(forceRefresh: true);
          cubit.emit(DataRefreshed());
        }
      },
    );
  }

  /// ✅ Build danh sách upcoming workouts - DÙNG STREAM
  Widget _buildUpcomingWorkouts(WorkoutTrackerCubit cubit, Color? textColor) {
    return StreamBuilder<List<UpcomingWorkout>>(
      stream: _upcomingWorkoutsStream, // ✅ Dùng stream thay vì BlocBuilder
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (snapshot.hasError) {
          print('❌ Stream error: ${snapshot.error}');
          return Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              LocaleKey.loadingError.tr,
              style: TextStyle(color: textColor),
            ),
          );
        }

        final upcomingWorkouts = snapshot.data ?? [];

        print('📋 Stream emitted ${upcomingWorkouts.length} workouts');

        // Empty state
        if (upcomingWorkouts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              LocaleKey.noScheduleYet.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          );
        }

        // ✅ Build list with stream data
        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: upcomingWorkouts.length,
          itemBuilder: (context, index) {
            final workout = upcomingWorkouts[index];

            return UpcomingWorkoutRow(
              key: ValueKey(
                'upcoming_${workout.categoryId}_${workout.scheduledTime.millisecondsSinceEpoch}',
              ),
              workout: workout,
              onNotificationToggle: (enabled) {
                _toggleNotification(index, enabled);
              },
              onDelete: () => _deleteScheduledWorkout(workout.categoryId),
            );
          },
        );
      },
    );
  }

  /// Build gym categories section
  Widget _buildGymCategories(Color? textColor, WorkoutTrackerCubit cubit) {
    return _buildCategorySection(
      title: LocaleKey.gymEx.tr,
      future: cubit.loadGymCategories(forceRefresh: false),
      cachedCategories: cubit.cachedGymCategories,
      emptyMessage: LocaleKey.noGymWorkouts.tr,
      textColor: textColor,
      cubit: cubit,
    );
  }

  /// Build home categories section
  Widget _buildHomeCategories(Color? textColor, WorkoutTrackerCubit cubit) {
    return _buildCategorySection(
      title: LocaleKey.homeEx.tr,
      future: cubit.loadHomeCategories(forceRefresh: false),
      cachedCategories: cubit.cachedHomeCategories,
      emptyMessage: LocaleKey.noHomeWorkouts.tr,
      textColor: textColor,
      cubit: cubit,
    );
  }

  /// Consolidated category section builder
  Widget _buildCategorySection({
    required String title,
    required Future<List<ExerciseCategory>> future,
    required List<ExerciseCategory>? cachedCategories,
    required String emptyMessage,
    required Color? textColor,
    required WorkoutTrackerCubit cubit,
  }) {
    return Column(
      children: [
        CustomSectionHeader(title: title, textColor: textColor),
        FutureBuilder<List<ExerciseCategory>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString(), textColor);
            }

            final categories = snapshot.data ?? cachedCategories ?? [];

            if (categories.isEmpty) {
              return _buildEmptyWidget(emptyMessage, textColor);
            }

            return _buildCategoryList(categories, cubit);
          },
        ),
      ],
    );
  }

  /// Build widget hiển thị lỗi
  Widget _buildErrorWidget(String error, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text("Error: $error", style: TextStyle(color: textColor)),
    );
  }

  /// Build widget hiển thị empty state
  Widget _buildEmptyWidget(String message, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(message, style: TextStyle(color: textColor)),
    );
  }

  /// Build category list with pre-loaded data (no FutureBuilder lag)
  Widget _buildCategoryList(
    List<ExerciseCategory> categories,
    WorkoutTrackerCubit cubit,
  ) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      buildWhen: (previous, current) => current is DataRefreshed,
      builder: (context, state) {
        final exerciseCounts = cubit.cachedExerciseCounts ?? {};
        final categoryProgress = cubit.cachedCategoryProgress ?? {};

        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryId = category.id ?? '';

            // Direct access to pre-loaded data - no async calls during scroll
            final exerciseCount = exerciseCounts[categoryId] ?? 0;
            final progressMap =
                categoryProgress[categoryId] ?? <String, WorkoutProgress>{};

            return InkWell(
              key: ValueKey('category_${category.id}_${state.hashCode}'),
              onTap: () => _navigateToWorkoutDetail(category, cubit),
              child: WhatTrainRow(
                key: ValueKey('row_${category.id}_${state.hashCode}'),
                category: category,
                exerciseCount: exerciseCount,
                progressMap: progressMap,
              ),
            );
          },
        );
      },
    );
  }

  /// Navigate đến màn hình workout detail
  Future<void> _navigateToWorkoutDetail(
    ExerciseCategory category,
    WorkoutTrackerCubit cubit,
  ) async {
    await navigateTo(
      context,
      BlocProvider.value(
        value: cubit,
        child: WorkoutDetailView(dObj: category.toJson()),
      ),
    );

    if (mounted) {
      await _refreshData();
      cubit.emit(DataRefreshed());
    }
  }
}
