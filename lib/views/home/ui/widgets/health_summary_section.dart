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
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: _buildWaterIntakeCard(media, theme)),
        SizedBox(width: media.width * 0.05),
        Expanded(
          child: Column(
            children: [
              _buildSleepCard(media, theme),
              SizedBox(height: media.width * 0.05),
              _buildCaloriesCard(media, theme),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WATER INTAKE CARD
  // ---------------------------------------------------------------------------
  Widget _buildWaterIntakeCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.95,
      theme: theme,
      child: Row(
        children: [
          _waterProgressBar(media),
          SizedBox(width: 10),
          Expanded(child: _waterInfo(theme, media)),
        ],
      ),
    );
  }

  Widget _waterProgressBar(Size media) {
    return SimpleAnimationProgressBar(
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
    );
  }

  Widget _waterInfo(ThemeData theme, Size media) {
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
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
        _gradientText("4 Liters", TColor.primaryG, fontSize: 14),
        const SizedBox(height: 10),
        Text(
          "Real time updates",
          style: TextStyle(color: TColor.gray, fontSize: 12),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: waterArr.map((wObj) {
            final isLast = wObj == waterArr.last;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _waterTimelineDot(media, isLast),
                  const SizedBox(width: 10),
                  _waterTimelineText(wObj),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _waterTimelineDot(Size media, bool isLast) {
    return Column(
      children: [
        Container(
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
            dashColor: TColor.secondaryColor1.withOpacity(0.5),
            axis: Axis.vertical,
          ),
      ],
    );
  }

  Widget _waterTimelineText(Map<String, dynamic> wObj) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(wObj["title"], style: TextStyle(color: TColor.gray, fontSize: 10)),
        _gradientText(wObj["subtitle"], TColor.secondaryG, fontSize: 12),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SLEEP CARD
  // ---------------------------------------------------------------------------
  Widget _buildSleepCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Sleep"),
          _gradientText("8h 20m", TColor.primaryG, fontSize: 14),
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

  // ---------------------------------------------------------------------------
  // CALORIES CARD
  // ---------------------------------------------------------------------------
  Widget _buildCaloriesCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Calories"),
          _gradientText("760 kCal", TColor.primaryG, fontSize: 14),
          const Spacer(),
          _caloriesCircle(media),
        ],
      ),
    );
  }

  Widget _caloriesCircle(Size media) {
    return Center(
      child: SizedBox(
        width: media.width * 0.2,
        height: media.width * 0.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _caloriesInnerBox(media),
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
    );
  }

  Widget _caloriesInnerBox(Size media) {
    return Container(
      width: media.width * 0.15,
      height: media.width * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.075),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          "230kCal\nleft",
          textAlign: TextAlign.center,
          style: TextStyle(color: TColor.white, fontSize: 11),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _baseCard({
    required double height,
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 2)],
      ),
      child: child,
    );
  }

  Widget _title(ThemeData theme, String text) {
    return Text(
      text,
      style: TextStyle(
        color: theme.textTheme.bodyMedium?.color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _gradientText(
    String text,
    List<Color> colors, {
    double fontSize = 14,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}
