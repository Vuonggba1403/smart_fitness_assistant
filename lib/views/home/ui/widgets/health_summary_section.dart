import 'package:flutter/material.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class HealthSummarySection extends StatelessWidget {
  final List<Map<String, dynamic>> waterArr;
  final double mediaWidth;

  const HealthSummarySection({
    super.key,
    required this.waterArr,
    required this.mediaWidth,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    final shadow = theme.shadowColor;

    return Row(
      children: [
        Expanded(
          child: _buildWaterIntakeCard(media, textColor, cardColor, shadow),
        ),
        SizedBox(width: media.width * 0.05),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSleepCard(media, textColor, cardColor, shadow),
              SizedBox(height: media.width * 0.05),
              _buildCaloriesCard(media, textColor, cardColor, shadow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterIntakeCard(
    Size media,
    Color? textColor,
    Color cardColor,
    Color shadow,
  ) {
    return Container(
      height: media.width * 0.95,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 2)],
      ),
      child: Row(
        children: [
          SimpleAnimationProgressBar(
            height: media.width * 0.85,
            width: media.width * 0.07,
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.purple,
            ratio: 0.5,
            direction: Axis.vertical,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(seconds: 3),
            borderRadius: BorderRadius.circular(15),
            gradientColor: LinearGradient(
              colors: TColor.primaryG,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Water Intake",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: TColor.primaryG,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                      Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                    );
                  },
                  child: Text(
                    "4 Liters",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Real time updates",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: waterArr.map((wObj) {
                    var isLast = wObj == waterArr.last;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: TColor.secondaryColor1.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            if (!isLast)
                              DottedDashedLine(
                                height: media.width * 0.078,
                                width: 0,
                                dashColor: TColor.secondaryColor1.withOpacity(
                                  0.5,
                                ),
                                axis: Axis.vertical,
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wObj["title"].toString(),
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 10,
                              ),
                            ),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: TColor.secondaryG,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(
                                  Rect.fromLTRB(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                );
                              },
                              child: Text(
                                wObj["subtitle"].toString(),
                                style: TextStyle(
                                  color: TColor.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(
    Size media,
    Color? textColor,
    Color cardColor,
    Color shadow,
  ) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sleep",
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              "8h 20m",
              style: TextStyle(
                color: TColor.white.withOpacity(0.7),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          Image.asset(
            "assets/img/sleep_grap.png",
            width: double.maxFinite,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(
    Size media,
    Color? textColor,
    Color cardColor,
    Color shadow,
  ) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calories",
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              "760 kCal",
              style: TextStyle(
                color: TColor.white.withOpacity(0.7),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: media.width * 0.2,
              height: media.width * 0.2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width * 0.15,
                    height: media.width * 0.15,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075),
                    ),
                    child: FittedBox(
                      child: Text(
                        "230kCal\nleft",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.white, fontSize: 11),
                      ),
                    ),
                  ),
                  SimpleCircularProgressBar(
                    progressStrokeWidth: 10,
                    backStrokeWidth: 10,
                    progressColors: TColor.primaryG,
                    backColor: Colors.grey.shade100,
                    valueNotifier: ValueNotifier(50),
                    startAngle: -180,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
