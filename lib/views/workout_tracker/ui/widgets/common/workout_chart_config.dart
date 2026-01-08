import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

/// Extension for workout chart configuration
extension WorkoutChartConfig on List<double> {
  /// Builds chart data for weekly workout stats
  List<LineChartBarData> toChartData() {
    return [
      LineChartBarData(
        isCurved: true,
        color: TColor.white,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: asMap().entries.map((entry) {
          return FlSpot((entry.key + 1).toDouble(), entry.value);
        }).toList(),
      ),
    ];
  }
}

/// Workout chart configuration helper
class WorkoutChartHelper {
  /// Touch data configuration
  static LineTouchData get touchData =>
      LineTouchData(handleBuiltInTouches: true);

  /// Right side titles (percentage)
  static SideTitles get rightTitles => SideTitles(
    getTitlesWidget: _rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  /// Bottom titles (days of week)
  static SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: _bottomTitleWidgets,
  );

  /// Grid data configuration
  static FlGridData get gridData => FlGridData(
    show: true,
    drawHorizontalLine: true,
    horizontalInterval: 25,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) {
      return FlLine(color: TColor.white.withOpacity(0.15), strokeWidth: 2);
    },
  );

  /// Builds right title widgets (percentage labels)
  static Widget _rightTitleWidgets(double value, TitleMeta meta) {
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

  /// Builds bottom title widgets (day labels)
  static Widget _bottomTitleWidgets(double value, TitleMeta meta) {
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
