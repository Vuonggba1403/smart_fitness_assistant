import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';

class BMICard extends StatelessWidget {
  const BMICard({super.key});

  double calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String getBMICategory(double bmi) {
    if (bmi < 16) return LocaleKey.classificationBMI1.tr;
    if (bmi < 17) return LocaleKey.classificationBMI2.tr;
    if (bmi < 18.5) return LocaleKey.classificationBMI3.tr;
    if (bmi < 25) return LocaleKey.classificationBMI4.tr;
    if (bmi < 30) return LocaleKey.classificationBMI5.tr;
    if (bmi < 35) return LocaleKey.classificationBMI6.tr;
    if (bmi < 40) return LocaleKey.classificationBMI7.tr;
    return LocaleKey.classificationBMI8.tr;
  }

  double getBMIPercentage(double bmi) {
    if (bmi < 10) return 0;
    if (bmi > 40) return 100;
    return ((bmi - 10) / 30) * 100;
  }

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        final user = context.watch<AuthenticationCubit>().userDataModel;

        final weight = _parseToDouble(user?.weight);
        final height = _parseToDouble(user?.height);
        final bmi = calculateBMI(weight, height);
        final bmiCategory = getBMICategory(bmi);
        final bmiPercentage = getBMIPercentage(bmi);
        final bmiColor = getBMIColor(bmi);

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
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKey.bmi.tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          bmi > 0 ? bmiCategory : "",
                          style: TextStyle(
                            color: textColor?.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        SizedBox(
                          width: 120,
                          height: 35,
                          child: RoundButton(
                            title: LocaleKey.seeMore.tr,
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
                          sections: showingSections(
                            bmi,
                            bmiPercentage,
                            bmiColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
    double bmi,
    double percentage,
    Color bmiColor,
  ) {
    return [
      PieChartSectionData(
        color: bmiColor,
        value: percentage,
        title: '',
        radius: 55,
        badgeWidget: Text(
          bmi > 0 ? bmi.toStringAsFixed(1) : "0.0",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      PieChartSectionData(
        color: Colors.white,
        value: 100 - percentage,
        title: '',
        radius: 45,
      ),
    ];
  }
}
