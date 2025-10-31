import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_drop_but.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/locale/translation_manager.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/activity_tracker_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/bmi_card.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/health_summary_section.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/heart_rate_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/lastest_workout_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/workout_progress_view.dart';
import '../../notifications/ui/notification_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const List<FlSpot> allSpots = [
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
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return _buildHomeView(context, state);
      },
    );
  }

  /// Giao diện chính của HomeView
  Widget _buildHomeView(BuildContext context, HomeState state) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: state is! HomeLoaded
            ? const Center(child: CustomCircleProgIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, state),
                    SizedBox(height: media.width * 0.05),
                    const BMICard(),
                    SizedBox(height: media.width * 0.05),
                    _buildTodayTarget(context),
                    SizedBox(height: media.width * 0.05),
                    _buildActivityStatus(context, state, media),
                    SizedBox(height: media.width * 0.05),
                    HealthSummarySection(
                      waterArr: state.waterArr,
                      mediaWidth: media.width,
                    ),
                    SizedBox(height: media.width * 0.1),
                    WorkoutProgressView(
                      lineBarsData: _getLineBarsData(),
                      showingTooltipOnSpots: state.showingTooltipOnSpots,
                      rightTitles: _getRightTitles(),
                      bottomTitles: _getBottomTitles(),
                    ),
                    SizedBox(height: media.width * 0.05),
                    LatestWorkoutView(
                      lastWorkoutArr: state.lastWorkoutArr,
                      onSeeMorePressed: () {},
                    ),
                    SizedBox(height: media.width * 0.1),
                  ],
                ),
              ),
      ),
    );
  }

  /// Header gồm: Welcome + DropDown ngôn ngữ + Notification
  Widget _buildHeader(BuildContext context, HomeLoaded state) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final hintText = state.currentLanguage == 'vi' ? 'VI' : 'EN';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKey.welcomeBack.tr,
              style: TextStyle(color: textColor, fontSize: 12),
            ),
            const Text(
              "Stefani Wong",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Row(
          children: [
            // DropDown chọn ngôn ngữ
            CustomDropButtonUnder(
              items: ["EN", "VI"],
              imagePaths: [
                "assets/img/english.png",
                "assets/img/vietnamese.png",
              ],
              hint: hintText,
              selectedValue: hintText,
              onChanged: (value) async {
                final translationManager = Get.find<TranslationManager>();
                final homeCubit = context.read<HomeCubit>();

                final localeMap = {
                  "EN": TranslationManager.fallbackLocaleUS,
                  "VI": TranslationManager.fallbackLocaleVN,
                };

                final languageMap = {"EN": "en", "VI": "vi"};

                if (localeMap.containsKey(value)) {
                  final newLanguage = languageMap[value]!;

                  // Only proceed if language is different
                  if (state.currentLanguage != newLanguage) {
                    await translationManager.updateLocale(localeMap[value]!);
                    homeCubit.updateLanguage(newLanguage);
                    CustomDialog.show(
                      context,
                      message: LocaleKey.langChanged.tr,
                    );
                  }
                }
              },
            ),

            // Nút Notification
            IconButton(
              onPressed: () => navigateTo(context, const NotificationView()),
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
    );
  }

  /// Ô Today Target
  Widget _buildTodayTarget(BuildContext context) {
    return CustomContainerCheck(
      name: "Today Target",
      title: "Check",
      onPressed: () => navigateTo(context, const ActivityTrackerView()),
    );
  }

  /// Biểu đồ nhịp tim
  Widget _buildActivityStatus(
    BuildContext context,
    HomeLoaded state,
    Size media,
  ) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKey.activityStatus.tr,
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
      ],
    );
  }

  // === Chart Data ===

  List<LineChartBarData> _getLineBarsData() => [
    _lineChartBarData1,
    _lineChartBarData2,
  ];

  LineChartBarData get _lineChartBarData1 => LineChartBarData(
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

  LineChartBarData get _lineChartBarData2 => LineChartBarData(
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

  SideTitles _getRightTitles() => SideTitles(
    getTitlesWidget: _rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  Widget _rightTitleWidgets(double value, TitleMeta meta) {
    const textMap = {
      0: '0%',
      20: '20%',
      40: '40%',
      60: '60%',
      80: '80%',
      100: '100%',
    };
    final text = textMap[value.toInt()] ?? '';

    return Text(
      text,
      style: TextStyle(color: TColor.gray, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  SideTitles _getBottomTitles() => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: _bottomTitleWidgets,
  );

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const days = ['', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final text = value.toInt() < days.length ? days[value.toInt()] : '';

    return SideTitleWidget(
      meta: meta,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(text, style: TextStyle(color: TColor.gray, fontSize: 12)),
      ),
    );
  }
}
