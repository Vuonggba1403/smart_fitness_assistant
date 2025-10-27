import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_drop_but.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';

class WorkoutProgressView extends StatelessWidget {
  final List<LineChartBarData> lineBarsData;
  final List<int> showingTooltipOnSpots;
  final SideTitles rightTitles;
  final SideTitles bottomTitles;

  const WorkoutProgressView({
    super.key,
    required this.lineBarsData,
    required this.showingTooltipOnSpots,
    required this.rightTitles,
    required this.bottomTitles,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color; // Màu text chính
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Workout Progress",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomDropButtonUnder(
                items: const ["Weekly", "Monthly"],
                hint: "Weekly",
                onChanged: (value) {
                  print("Selected: $value");
                },
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(left: 15),
          height: media.width * 0.5,
          width: double.maxFinite,
          child: LineChart(
            LineChartData(
              showingTooltipIndicators: showingTooltipOnSpots.map((spotIndex) {
                // Check if spotIndex is within bounds of any bar
                final validBars = lineBarsData
                    .asMap()
                    .entries
                    .where((entry) => spotIndex < entry.value.spots.length)
                    .toList();

                if (validBars.isEmpty) {
                  return ShowingTooltipIndicators([]);
                }

                final barEntry = validBars.first;
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    barEntry.value,
                    barEntry.key,
                    barEntry.value.spots[spotIndex],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                      if (response == null || response.lineBarSpots == null) {
                        return;
                      }
                      if (event is FlTapUpEvent) {
                        final spotIndex =
                            response.lineBarSpots!.first.spotIndex;
                        context.read<HomeCubit>().updateTooltipSpot(spotIndex);
                      }
                    },
                mouseCursorResolver:
                    (FlTouchEvent event, LineTouchResponse? response) {
                      if (response == null || response.lineBarSpots == null) {
                        return SystemMouseCursors.basic;
                      }
                      return SystemMouseCursors.click;
                    },
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          FlLine(color: Colors.transparent),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: TColor.secondaryColor1,
                                ),
                          ),
                        );
                      }).toList();
                    },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(20),
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        "${lineBarSpot.x.toInt()} mins ago",
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lineBarsData,
              minY: -0.5,
              maxY: 110,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(),
                topTitles: AxisTitles(),
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
                    color: TColor.gray.withOpacity(0.15),
                    strokeWidth: 2,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
