import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import '../../../../core/functions/common.dart';

class StatisticView extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;

  const StatisticView({super.key, required this.date1, required this.date2});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final statArr = [
      {
        "title": "Lose Weight",
        "diff_per": "33",
        "month_1_per": "33%",
        "month_2_per": "67%",
      },
      {
        "title": "Height Increase",
        "diff_per": "88",
        "month_1_per": "88%",
        "month_2_per": "12%",
      },
      {
        "title": "Muscle Mass Increase",
        "diff_per": "57",
        "month_1_per": "57%",
        "month_2_per": "43%",
      },
      {
        "title": "Abs",
        "diff_per": "89",
        "month_1_per": "89%",
        "month_2_per": "11%",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChart(media),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateToString(date1, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              dateToString(date2, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: statArr.length,
          itemBuilder: (context, index) {
            var iObj = statArr[index];
            return _buildStatRow(context, iObj, media);
          },
        ),
        const SizedBox(height: 20),
        RoundButton(
          title: "Back to Home",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildChart(Size media) {
    return SizedBox(
      height: media.width * 0.5,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            _line(Colors.deepPurpleAccent, [
              FlSpot(1, 35),
              FlSpot(2, 70),
              FlSpot(3, 40),
              FlSpot(4, 80),
              FlSpot(5, 25),
              FlSpot(6, 70),
              FlSpot(7, 35),
            ]),
            _line(Colors.orangeAccent.withOpacity(0.6), [
              FlSpot(1, 80),
              FlSpot(2, 50),
              FlSpot(3, 90),
              FlSpot(4, 40),
              FlSpot(5, 80),
              FlSpot(6, 35),
              FlSpot(7, 60),
            ]),
          ],
          minY: -0.5,
          maxY: 110,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: _bottomTitles()),
            rightTitles: AxisTitles(sideTitles: _rightTitles()),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: TColor.lightGray, strokeWidth: 2),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  LineChartBarData _line(Color color, List<FlSpot> spots) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: spots,
    );
  }

  Widget _buildStatRow(BuildContext context, Map iObj, Size media) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          iObj["title"].toString(),
          style: TextStyle(
            color: TColor.gray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 25,
              child: Text(
                iObj["month_1_per"].toString(),
                textAlign: TextAlign.right,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
            ),
            SimpleAnimationProgressBar(
              height: 10,
              width: media.width - 120,
              backgroundColor: TColor.primaryColor1,
              foregroundColor: const Color(0xffFFB2B1),
              ratio: (double.tryParse(iObj["diff_per"]) ?? 0) / 100,
              direction: Axis.horizontal,
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(seconds: 3),
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(
              width: 25,
              child: Text(
                iObj["month_2_per"].toString(),
                textAlign: TextAlign.left,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SideTitles _bottomTitles() => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: (value, meta) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
      return SideTitleWidget(
        meta: meta,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            value >= 1 && value <= 7 ? months[value.toInt() - 1] : '',
            style: TextStyle(color: TColor.gray, fontSize: 12),
          ),
        ),
      );
    },
  );

  SideTitles _rightTitles() => SideTitles(
    showTitles: true,
    interval: 20,
    reservedSize: 40,
    getTitlesWidget: (value, meta) {
      if (value % 20 != 0) return Container();
      return Text(
        '${value.toInt()}%',
        style: TextStyle(color: TColor.gray, fontSize: 12),
        textAlign: TextAlign.center,
      );
    },
  );
}
