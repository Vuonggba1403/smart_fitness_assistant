import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ THÊM import
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_sliverbar.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart'; // ✅ Thêm import
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workour_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workout_schedule_view.dart';
import '../../../locale/locale_key.dart';
import 'widgets/common/upcoming_workout_row.dart';
import 'widgets/common/what_train_row.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/time_picker_dialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_section_header.dart'; // ✅ THÊM import

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key, required this.title});
  final String title;

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  // ✅ THÊM Supabase instance
  final _supabase = Supabase.instance.client;

  late Stream<List<ExerciseCategory>> _categoriesStream;
  late Stream<List<ExerciseCategory>> _gymCategoriesStream; // ✅ THÊM
  late Stream<List<ExerciseCategory>> _homeCategoriesStream; // ✅ THÊM
  final NotificationService _notificationService = NotificationService();
  List<UpcomingWorkout> _upcomingWorkouts = [];
  int _rebuildKey = 0;
  List<double> _weeklyStats = List.filled(7, 0.0);
  final GlobalKey _upcomingKey = GlobalKey();
  final GlobalKey _gymCategoriesKey = GlobalKey(); // ✅ THÊM
  final GlobalKey _homeCategoriesKey = GlobalKey(); // ✅ THÊM

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadInitialData();
    _forceRefreshStreams();
  }

  // ✅ THÊM: Auto refresh khi quay lại màn hình
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Reload data mỗi khi quay lại màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  /// ✅ Force refresh streams
  void _forceRefreshStreams() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Force rebuild tất cả streams
        });
      }
    });
  }

  /// ✅ Load tất cả data khi khởi động app
  Future<void> _loadInitialData() async {
    final cubit = context.read<WorkoutTrackerCubit>();

    // Load parallel để nhanh hơn
    await Future.wait([
      cubit.loadWeeklyWorkoutStats().then((stats) {
        if (mounted) {
          setState(() {
            _weeklyStats = stats;
          });
        }
      }),
      cubit.loadUpcomingWorkouts().then((workouts) {
        if (mounted) {
          setState(() {
            _upcomingWorkouts = workouts;
          });
        }
      }),
    ]);
  }

  /// ✅ Refresh data sau khi hoàn thành workout
  Future<void> _refreshData() async {
    final cubit = context.read<WorkoutTrackerCubit>();
    cubit.clearCache(); // ✅ Clear cache trước khi load lại

    await Future.wait([
      cubit.loadWeeklyWorkoutStats(forceRefresh: true).then((stats) {
        if (mounted) {
          setState(() {
            _weeklyStats = stats;
          });
        }
      }),
      cubit.loadUpcomingWorkouts(forceRefresh: true).then((workouts) {
        if (mounted) {
          setState(() {
            _upcomingWorkouts = workouts;
          });
        }
      }),
    ]);
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// ✅ Toggle notification cho workout với chọn giờ
  Future<void> _toggleNotification(int index, bool enabled) async {
    final workout = _upcomingWorkouts[index];

    if (enabled) {
      // ✅ Hiển thị dialog chọn giờ
      final scheduledTime = await WorkoutTimePicker.show(context);

      if (scheduledTime == null) {
        // ❌ User hủy → Không làm gì
        return;
      }

      final now = DateTime.now();

      // ✅ Kiểm tra thời gian tập phải sau ít nhất 1 phút
      final minScheduledTime = now.add(const Duration(minutes: 1));

      if (scheduledTime.isBefore(minScheduledTime)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vui lòng chọn thời gian ít nhất sau ${_formatTime(minScheduledTime)}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // ✅ FIX: Báo ĐÚNG GIỜ user chọn (không trừ 15 phút)
      await _notificationService.scheduleWorkoutNotification(
        id: workout.categoryId.hashCode,
        title: '⏰ Đã đến giờ tập luyện!',
        body: '${workout.categoryName} - Bắt đầu ngay thôi! 💪',
        scheduledTime: scheduledTime, // ✅ Đúng giờ user chọn
      );

      // ✅ Debug: Kiểm tra pending notifications
      final pending = await _notificationService.getPendingNotifications();
      print('📋 Pending notifications: ${pending.length}');
      for (final p in pending) {
        print('   - ID: ${p.id}, Title: ${p.title}');
      }

      if (mounted) {
        // ✅ Cập nhật state với thời gian mới
        setState(() {
          _upcomingWorkouts[index] = workout.copyWith(
            isNotificationEnabled: true,
            scheduledTime: scheduledTime,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Đã đặt nhắc nhở lúc ${_formatTime(scheduledTime)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // ✅ TẮT notification
      await _notificationService.cancelNotification(
        workout.categoryId.hashCode,
      );

      if (mounted) {
        setState(() {
          _upcomingWorkouts[index] = workout.copyWith(
            isNotificationEnabled: false,
          );
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Đã hủy nhắc nhở'),
        //     backgroundColor: Colors.orange,
        //   ),
        // );
        showCustomDelightToastBar(
          context,
          'Đã hủy nhắc nhở',
          Icon(Icons.notifications_off, color: TColor.white),
        );
      }
    }
  }

  /// ✅ Format time only (HH:mm)
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// ✅ Format datetime cho thông báo
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month';
  }

  /// ✅ Delete scheduled workout
  Future<void> _deleteScheduledWorkout(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Xóa schedule từ DB
      await _supabase
          .from('scheduled_workouts')
          .delete()
          .eq('for_user', userId)
          .eq('category_id', categoryId);

      // ✅ Hủy notification
      await _notificationService.cancelNotification(categoryId.hashCode);

      // ✅ Reload data
      final cubit = context.read<WorkoutTrackerCubit>();
      final updatedWorkouts = await cubit.loadUpcomingWorkouts(
        forceRefresh: true,
      );

      if (mounted) {
        setState(() {
          _upcomingWorkouts = updatedWorkouts;
        });

        showCustomDelightToastBar(
          context,
          'Đã xóa lịch tập',
          Icon(Icons.delete, color: TColor.white),
        );
      }
    } catch (e) {
      print('❌ Error deleting schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocProvider(
      create: (context) => WorkoutTrackerCubit(),
      child: Builder(
        builder: (context) {
          final cubit = context.read<WorkoutTrackerCubit>();

          // ✅ Tạo 3 streams riêng biệt
          _categoriesStream = cubit.streamExerciseCategoriesWithCount();
          _gymCategoriesStream = cubit.streamGymCategories();
          _homeCategoriesStream = cubit.streamHomeCategories();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  CustomSliverAppBar(text: widget.title),

                  /// Phần biểu đồ (Chart Section) - ✅ Hiển thị dữ liệu thực
                  SliverAppBar(
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
                      child: LineChart(
                        LineChartData(
                          lineTouchData: lineTouchData1,
                          lineBarsData:
                              _buildChartData(), // ✅ Dùng dữ liệu thực
                          minY: -0.5,
                          maxY: 110,
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: const AxisTitles(),
                            topTitles: const AxisTitles(),
                            bottomTitles: AxisTitles(sideTitles: bottomTitles),
                            rightTitles: AxisTitles(sideTitles: rightTitles),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            horizontalInterval: 25,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: TColor.white.withOpacity(0.15),
                                strokeWidth: 2,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ];
              },

              body: Container(
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
                        Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),

                        /// Lịch tập hàng ngày (Daily workout)
                        CustomContainerCheck(
                          name: LocaleKey.dailyWorkoutSchedule.tr,
                          title: LocaleKey.check.tr,
                          onPressed: () async {
                            // ✅ Chờ quay lại từ WorkoutScheduleView
                            await navigateTo(
                              context,
                              const WorkoutScheduleView(),
                            );

                            // ✅ Refresh data sau khi quay lại
                            if (mounted) {
                              await _refreshData();
                            }
                          },
                        ),

                        SizedBox(height: media.width * 0.05),

                        /// ✅ Upcoming Workouts - Không dùng FutureBuilder
                        _upcomingWorkouts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Chưa có lịch tập nào! ✨\nThêm lịch tại Daily Workout Schedule",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _upcomingWorkouts.length,
                                itemBuilder: (context, index) {
                                  final workout = _upcomingWorkouts[index];

                                  return UpcomingWorkoutRow(
                                    key: ValueKey(
                                      'upcoming_${workout.categoryId}_$index',
                                    ),
                                    workout: workout,
                                    onNotificationToggle: (enabled) {
                                      _toggleNotification(index, enabled);
                                    },
                                    onDelete: () {
                                      _deleteScheduledWorkout(
                                        workout.categoryId,
                                      ); // ✅ Delete
                                    },
                                  );
                                },
                              ),

                        SizedBox(height: media.width * 0.05),

                        // ✅ BÀI TẬP TẠI PHÒNG GYM - Dùng CustomSectionHeader
                        CustomSectionHeader(
                          title: LocaleKey.gymEx.tr,
                          textColor: textColor,
                        ),

                        StreamBuilder<List<ExerciseCategory>>(
                          key: _gymCategoriesKey,
                          stream: _gymCategoriesStream, // ✅ Dùng stream GYM
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }

                            final categories = snapshot.data ?? [];

                            if (categories.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Không có bài tập tại phòng gym",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final cubit = context
                                    .read<WorkoutTrackerCubit>();

                                return InkWell(
                                  key: ValueKey(
                                    'gym_category_${category.id}_$index',
                                  ),
                                  onTap: () async {
                                    await navigateTo(
                                      context,
                                      BlocProvider.value(
                                        value: cubit,
                                        child: WorkoutDetailView(
                                          dObj: category.toJson(),
                                        ),
                                      ),
                                    );

                                    await _refreshData();
                                    setState(() {
                                      _rebuildKey++;
                                    });
                                  },
                                  child: FutureBuilder<List<dynamic>>(
                                    future: Future.wait([
                                      cubit.getExerciseCount(category.id ?? ''),
                                      cubit.loadProgress(category.id ?? ''),
                                    ]),
                                    builder: (context, snapshot) {
                                      final exerciseCount = snapshot.hasData
                                          ? snapshot.data![0] as int
                                          : 0;
                                      final progressMap = snapshot.hasData
                                          ? snapshot.data![1]
                                                as Map<String, WorkoutProgress>
                                          : <String, WorkoutProgress>{};

                                      return WhatTrainRow(
                                        key: ValueKey(
                                          'gym_row_${category.id}_$_rebuildKey',
                                        ),
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
                        ),

                        SizedBox(height: media.width * 0.1),

                        // ✅ BÀI TẬP TẠI NHÀ - Dùng CustomSectionHeader
                        CustomSectionHeader(
                          title: LocaleKey.homeEx.tr,
                          textColor: textColor,
                        ),

                        StreamBuilder<List<ExerciseCategory>>(
                          key: _homeCategoriesKey,
                          stream: _homeCategoriesStream, // ✅ Dùng stream HOME
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }

                            final categories = snapshot.data ?? [];

                            if (categories.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Không có bài tập tại nhà",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final cubit = context
                                    .read<WorkoutTrackerCubit>();

                                return InkWell(
                                  key: ValueKey(
                                    'home_category_${category.id}_$index',
                                  ),
                                  onTap: () async {
                                    await navigateTo(
                                      context,
                                      BlocProvider.value(
                                        value: cubit,
                                        child: WorkoutDetailView(
                                          dObj: category.toJson(),
                                        ),
                                      ),
                                    );

                                    await _refreshData();
                                    setState(() {
                                      _rebuildKey++;
                                    });
                                  },
                                  child: FutureBuilder<List<dynamic>>(
                                    future: Future.wait([
                                      cubit.getExerciseCount(category.id ?? ''),
                                      cubit.loadProgress(category.id ?? ''),
                                    ]),
                                    builder: (context, snapshot) {
                                      final exerciseCount = snapshot.hasData
                                          ? snapshot.data![0] as int
                                          : 0;
                                      final progressMap = snapshot.hasData
                                          ? snapshot.data![1]
                                                as Map<String, WorkoutProgress>
                                          : <String, WorkoutProgress>{};

                                      return WhatTrainRow(
                                        key: ValueKey(
                                          'home_row_${category.id}_$_rebuildKey',
                                        ),
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
                        ),

                        SizedBox(height: media.width * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Build chart data từ weekly stats thực tế
  List<LineChartBarData> _buildChartData() {
    return [
      LineChartBarData(
        isCurved: true,
        color: TColor.white,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: _weeklyStats.asMap().entries.map((entry) {
          return FlSpot((entry.key + 1).toDouble(), entry.value);
        }).toList(),
      ),
    ];
  }

  LineTouchData get lineTouchData1 => LineTouchData(handleBuiltInTouches: true);

  SideTitles get rightTitles => SideTitles(
    getTitlesWidget: rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
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

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
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
}
