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
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workour_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import '../../../locale/locale_key.dart';
import 'widgets/common/upcoming_workout_row.dart';
import 'widgets/common/what_train_row.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:smart_fitness_assistant/views/schedule_management/ui/widgets/time_picker_dialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_section_header.dart';
import 'package:smart_fitness_assistant/views/schedule_management/logic/cubit/schedule_cubit.dart';

/// Màn hình chính hiển thị danh sách workout và thống kê
class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key, required this.title});
  final String title;

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  late Stream<List<ExerciseCategory>> _categoriesStream;
  late Stream<List<ExerciseCategory>> _gymCategoriesStream;
  late Stream<List<ExerciseCategory>> _homeCategoriesStream;
  late Stream<List<UpcomingWorkout>> _upcomingWorkoutsStream; // ✅ ADD

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    // ✅ FIX: Load data ngay khi mount
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ FIX: Chỉ refresh khi thực sự cần (khi back từ detail screen)
    // Không refresh liên tục để giữ cache
  }

  /// Khởi tạo notification service
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// Load dữ liệu ban đầu khi mở màn hình
  void _loadInitialData() {
    print('🔄 Loading initial data in WorkoutTrackerView');

    final cubit = context.read<WorkoutTrackerCubit>();

    // ✅ FIX: Load từ cache trước (forceRefresh: false)
    cubit.loadWeeklyWorkoutStats(forceRefresh: false);
    cubit.loadUpcomingWorkouts(forceRefresh: false);
  }

  /// Refresh toàn bộ dữ liệu - ✅ Chỉ gọi khi thực sự cần
  Future<void> _refreshData() async {
    print('🔄 Manual refresh data');

    final cubit = context.read<WorkoutTrackerCubit>();
    await cubit.loadWeeklyWorkoutStats(forceRefresh: true);
    await cubit.loadUpcomingWorkouts(forceRefresh: true);
  }

  /// Bật/tắt notification cho workout
  Future<void> _toggleNotification(int index, bool enabled) async {
    final cubit = context.read<WorkoutTrackerCubit>();
    final workouts = cubit.cachedUpcomingWorkouts ?? [];

    if (index >= workouts.length) return;

    final workout = workouts[index];
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (enabled) {
      await _enableNotification(workout, userId);
    } else {
      await _disableNotification(workout, userId);
    }
  }

  /// Bật notification cho workout
  Future<void> _enableNotification(
    UpcomingWorkout workout,
    String userId,
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

    final notificationId = _generateNotificationId(userId, workout.categoryId);

    await _notificationService.scheduleWorkoutNotification(
      id: notificationId,
      title: LocaleKey.workoutTimeNotification.tr,
      body: '${workout.categoryName} - ${LocaleKey.startNow.tr}',
      scheduledTime: scheduledTime,
    );

    print('🔔 Enabling notification for: ${workout.categoryName}');

    // ✅ FIX: Update database trước
    await _supabase
        .from('scheduled_workouts')
        .update({'has_notification': true})
        .eq('for_user', userId)
        .eq('category_id', workout.categoryId);

    if (mounted) {
      final cubit = context.read<WorkoutTrackerCubit>();

      print('🔄 Reloading after notification toggle...');

      // ✅ Force reload và emit state
      await cubit.loadUpcomingWorkouts(forceRefresh: true);

      // ✅ Trigger manual setState
      if (mounted) {
        setState(() {});
      }

      AppSnackBar.success(
        context,
        '${LocaleKey.setReminderAt.tr} ${_formatTime(scheduledTime)}',
      );
    }
  }

  /// Tắt notification cho workout
  Future<void> _disableNotification(
    UpcomingWorkout workout,
    String userId,
  ) async {
    final notificationId = _generateNotificationId(userId, workout.categoryId);
    await _notificationService.cancelNotification(notificationId);

    print('🔔 Disabling notification for: ${workout.categoryName}');

    // ✅ Chỉ cần update database - Stream sẽ tự động update UI
    await _supabase
        .from('scheduled_workouts')
        .update({'has_notification': false})
        .eq('for_user', userId)
        .eq('category_id', workout.categoryId);

    if (mounted) {
      AppSnackBar.success(context, LocaleKey.cancelledReminder.tr);
    }
  }

  /// Sinh notification ID duy nhất cho mỗi workout
  int _generateNotificationId(String userId, String categoryId) {
    return 200000 +
        (userId.hashCode.abs() % 10000) +
        (categoryId.hashCode.abs() % 10000);
  }

  /// Format thời gian thành HH:mm
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
        BlocProvider(create: (context) => ScheduleCubit()),
      ],
      child: Builder(
        builder: (context) {
          final cubit = context.read<WorkoutTrackerCubit>();

          _categoriesStream = cubit.streamExerciseCategoriesWithCount();
          _gymCategoriesStream = cubit.streamGymCategories();
          _homeCategoriesStream = cubit.streamHomeCategories();
          _upcomingWorkoutsStream = cubit.streamUpcomingWorkouts(); // ✅ ADD

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

  /// Build phần biểu đồ thống kê
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
          // ✅ FIX: Rebuild khi state changes
          buildWhen: (previous, current) {
            return current is WeeklyStatsUpdated || current is DataRefreshed;
          },
          builder: (context, state) {
            final weeklyStats = cubit.cachedWeeklyStats ?? List.filled(7, 0.0);

            return LineChart(
              LineChartData(
                lineTouchData: _lineTouchData,
                lineBarsData: _buildChartData(weeklyStats),
                minY: -0.5,
                maxY: 110,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                  rightTitles: AxisTitles(sideTitles: _rightTitles),
                ),
                gridData: _gridData,
                borderData: FlBorderData(show: false),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build phần body chính
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
        borderRadius: BorderRadius.circular(3),
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
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: TColor.primaryColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: TColor.primaryColor1.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 40,
                  color: TColor.primaryColor1.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKey.noScheduleYet.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKey.tapToAddSchedule.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
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

  /// Build danh sách categories tại gym
  Widget _buildGymCategories(Color? textColor, WorkoutTrackerCubit cubit) {
    return Column(
      children: [
        CustomSectionHeader(title: LocaleKey.gymEx.tr, textColor: textColor),
        StreamBuilder<List<ExerciseCategory>>(
          stream: _gymCategoriesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString(), textColor);
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return _buildEmptyWidget(LocaleKey.noGymWorkouts.tr, textColor);
            }

            return _buildCategoryList(categories, cubit);
          },
        ),
      ],
    );
  }

  /// Build danh sách categories tại nhà
  Widget _buildHomeCategories(Color? textColor, WorkoutTrackerCubit cubit) {
    return Column(
      children: [
        CustomSectionHeader(title: LocaleKey.homeEx.tr, textColor: textColor),
        StreamBuilder<List<ExerciseCategory>>(
          stream: _homeCategoriesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString(), textColor);
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return _buildEmptyWidget(LocaleKey.noHomeWorkouts.tr, textColor);
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

  /// Build danh sách categories
  Widget _buildCategoryList(
    List<ExerciseCategory> categories,
    WorkoutTrackerCubit cubit,
  ) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      // ✅ FIX: Rebuild khi data refresh
      buildWhen: (previous, current) {
        return current is DataRefreshed;
      },
      builder: (context, state) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return InkWell(
              key: ValueKey('category_${category.id}_${state.hashCode}'),
              onTap: () => _navigateToWorkoutDetail(category, cubit),
              child: FutureBuilder<List<dynamic>>(
                // ✅ FIX: Rebuild future mỗi khi state changes
                key: ValueKey('future_${category.id}_${state.hashCode}'),
                future: Future.wait([
                  cubit.getExerciseCount(category.id ?? ''),
                  cubit.loadProgress(category.id ?? ''),
                ]),
                builder: (context, snapshot) {
                  final exerciseCount = snapshot.hasData
                      ? snapshot.data![0] as int
                      : 0;
                  final progressMap = snapshot.hasData
                      ? snapshot.data![1] as Map<String, WorkoutProgress>
                      : <String, WorkoutProgress>{};

                  return WhatTrainRow(
                    key: ValueKey('row_${category.id}_${state.hashCode}'),
                    category: category,
                    exerciseCount: exerciseCount,
                    progressMap: progressMap,
                  );
                },
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

    // ✅ FIX: Force reload data và emit state mới
    if (mounted) {
      await _refreshData();
      cubit.emit(DataRefreshed()); // ✅ Trigger rebuild
    }
  }

  // ============ Chart Configuration ============

  /// Build dữ liệu cho biểu đồ
  List<LineChartBarData> _buildChartData(List<double> weeklyStats) {
    return [
      LineChartBarData(
        isCurved: true,
        color: TColor.white,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: weeklyStats.asMap().entries.map((entry) {
          return FlSpot((entry.key + 1).toDouble(), entry.value);
        }).toList(),
      ),
    ];
  }

  LineTouchData get _lineTouchData => LineTouchData(handleBuiltInTouches: true);

  SideTitles get _rightTitles => SideTitles(
    getTitlesWidget: _rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  /// Build labels cho trục Y (phần trăm)
  Widget _rightTitleWidgets(double value, TitleMeta meta) {
    const labels = {
      0: '0%',
      20: '20%',
      40: '40%',
      60: '60%',
      80: '80%',
      100: '100%',
    };

    if (!labels.containsKey(value.toInt())) return Container();

    return Text(
      labels[value.toInt()]!,
      style: TextStyle(color: TColor.white, fontSize: 12),
    );
  }

  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: _bottomTitleWidgets,
  );

  /// Build labels cho trục X (các ngày trong tuần)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const days = {
      1: 'Sun',
      2: 'Mon',
      3: 'Tue',
      4: 'Wed',
      5: 'Thu',
      6: 'Fri',
      7: 'Sat',
    };

    return SideTitleWidget(
      meta: meta,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          days[value.toInt()] ?? "",
          style: TextStyle(color: TColor.white, fontSize: 12),
        ),
      ),
    );
  }

  FlGridData get _gridData => FlGridData(
    show: true,
    drawHorizontalLine: true,
    horizontalInterval: 25,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) {
      return FlLine(color: TColor.white.withOpacity(0.15), strokeWidth: 2);
    },
  );
}
