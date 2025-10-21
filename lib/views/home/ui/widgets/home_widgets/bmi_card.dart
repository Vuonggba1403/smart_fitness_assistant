import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/common_widget/round_button.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class BMICard extends StatelessWidget {
  const BMICard({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Container(
      height: media.width * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.075),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/bg_dots.png",
            height: media.width * 0.4,
            width: double.maxFinite,
            fit: BoxFit.fitHeight,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BMI (Body Mass Index)",
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "You have a normal weight",
                      style: TextStyle(
                        color: TColor.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: media.width * 0.05),
                    SizedBox(
                      width: 120,
                      height: 35,
                      child: RoundButton(
                        title: "View More",
                        type: RoundButtonType.bgSGradient,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                      startDegreeOffset: 250,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 1,
                      centerSpaceRadius: 0,
                      sections: showingSections(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      var color0 = TColor.secondaryColor1;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: color0,
            value: 33,
            title: '',
            radius: 55,
            titlePositionPercentageOffset: 0.55,
            badgeWidget: const Text(
              "20,1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.white,
            value: 75,
            title: '',
            radius: 45,
            titlePositionPercentageOffset: 0.55,
          );

        default:
          throw Error();
      }
    });
  }
}
