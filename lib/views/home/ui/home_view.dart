import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_drop_but.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/activity_tracker_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/bmi_card.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/home_widgets/health_summary_section.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/home_widgets/heart_rate_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/lastest_workout_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/workout_progress_view.dart';
import '../../../core/functions/colo_extension.dart';
import '../../notifications/ui/notification_view.dart';
import '../logic/cubit/home_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is! HomeLoaded) {
            return const Scaffold(
              body: Center(child: CustomCircleProgIndicator()),
            );
          }
          return _buildHomeScaffold(context, state);
        },
      ),
    );
  }

  Widget _buildHomeScaffold(BuildContext context, HomeLoaded state) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context); // 🌙 Lấy theme động
    final textColor = theme.textTheme.bodyMedium?.color; // Màu text chính
    final cardColor = theme.cardColor; // Màu nền cho các card
    final shadow = theme.shadowColor; // Màu shadow động

    return Scaffold(
      // 🌙 Màu nền động
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                        Text(
                          "Stefani Wong",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.secondaryG),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: CustomDropButtonUnder(
                            items: ["Weekly", "Monthly"],
                            hint: "Weekly",
                            onChanged: (value) {
                              print("Selected: $value");
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            navigateTo(context, NotificationView());
                          },
                          icon: Image.asset(
                            "assets/img/notification_active.png",
                            width: 25,
                            height: 25,
                            color: textColor,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),
                //BMI
                BMICard(),
                SizedBox(height: media.width * 0.05),
                //Custom container
                CustomContainerCheck(
                  name: "Today Target",
                  title: "Check",
                  onPressed: () {
                    // Handle check button press
                    navigateTo(context, ActivityTrackerView());
                  },
                ),
                SizedBox(height: media.width * 0.05),
                Text(
                  "Activity Status",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: media.width * 0.02),
                HeartRateView(
                  allSpots: allSpots,
                  showingTooltipOnSpots: state.showingTooltipOnSpots,
                ),
                SizedBox(height: media.width * 0.05),
                HealthSummarySection(
                  waterArr: state.waterArr,
                  mediaWidth: media.width,
                ),
                SizedBox(height: media.width * 0.1),
                WorkoutProgressView(
                  lineBarsData: lineBarsData1,
                  showingTooltipOnSpots: state.showingTooltipOnSpots,
                  rightTitles: rightTitles,
                  bottomTitles: bottomTitles,
                ),
                SizedBox(height: media.width * 0.05),
                LatestWorkoutView(
                  lastWorkoutArr: state.lastWorkoutArr,
                  onSeeMorePressed: () {
                    // Handle see more
                  },
                ),
                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(
      colors: [
        TColor.primaryColor2.withOpacity(0.5),
        TColor.primaryColor1.withOpacity(0.5),
      ],
    ),
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
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
    gradient: LinearGradient(
      colors: [
        TColor.secondaryColor2.withOpacity(0.5),
        TColor.secondaryColor1.withOpacity(0.5),
      ],
    ),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
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
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(
      text,
      style: TextStyle(color: TColor.gray, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(color: TColor.gray, fontSize: 12);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: Padding(padding: const EdgeInsets.only(top: 8.0), child: text),
    );
  }
}
