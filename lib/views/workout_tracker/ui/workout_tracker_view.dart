import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_sliverbar.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workour_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workout_schedule_view.dart';
import '../../../locale/locale_key.dart';
import 'widgets/common/upcoming_workout_row.dart';
import 'widgets/common/what_train_row.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key, required this.title});
  final String title;

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  late Stream<List<Map<String, dynamic>>> _categoriesStream;

  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Fullbody Workout",
      "time": "Today, 03:00pm",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Upperbody Workout",
      "time": "June 05, 02:00pm",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocProvider(
      create: (context) => WorkoutTrackerCubit(),
      child: Builder(
        builder: (context) {
          _categoriesStream = context
              .read<WorkoutTrackerCubit>()
              .streamExerciseCategories();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  CustomSliverAppBar(text: widget.title),

                  /// Chart Section
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
                          lineBarsData: lineBarsData1,
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

                        /// Slider icon
                        Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),

                        /// Daily workout
                        CustomContainerCheck(
                          name: "Daily Workout Schedule",
                          title: "Check",
                          onPressed: () =>
                              navigateTo(context, const WorkoutScheduleView()),
                        ),

                        SizedBox(height: media.width * 0.05),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Upcoming Workout",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "See More",
                                style: TextStyle(
                                  color: textColor?.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// Upcoming list
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: latestArr.length,
                          itemBuilder: (context, index) {
                            var wObj = latestArr[index];
                            return UpcomingWorkoutRow(wObj: wObj, index: index);
                          },
                        ),

                        SizedBox(height: media.width * 0.05),

                        /// Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKey.titleEx.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        /// Categories list
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _categoriesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

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
                                  "No exercises found",
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
                                final wObj = categories[index];
                                return InkWell(
                                  onTap: () {
                                    navigateTo(
                                      context,
                                      BlocProvider.value(
                                        value: context
                                            .read<WorkoutTrackerCubit>(),
                                        child: WorkoutDetailView(dObj: wObj),
                                      ),
                                    );
                                  },
                                  child: WhatTrainRow(wObj: wObj),
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

  /// Line chart settings
  LineTouchData get lineTouchData1 => LineTouchData(handleBuiltInTouches: true);

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    color: TColor.white,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 35),
      FlSpot(2, 70),
      FlSpot(3, 40),
      FlSpot(4, 80),
      FlSpot(5, 25),
      FlSpot(6, 70),
      FlSpot(7, 35),
    ],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    color: TColor.white.withOpacity(0.5),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 80),
      FlSpot(2, 50),
      FlSpot(3, 90),
      FlSpot(4, 40),
      FlSpot(5, 80),
      FlSpot(6, 35),
      FlSpot(7, 60),
    ],
  );

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
