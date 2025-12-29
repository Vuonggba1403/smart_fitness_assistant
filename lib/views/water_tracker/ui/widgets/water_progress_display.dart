import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/components/water_progress_painter.dart';

class WaterProgressDisplay extends StatelessWidget {
  final int totalMl;
  final int goalMl;
  final double progress;
  final VoidCallback onTap;

  const WaterProgressDisplay({
    super.key,
    required this.totalMl,
    required this.goalMl,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: media.width * 0.7,
          height: media.width * 0.7,
          child: CustomPaint(painter: WaterProgressPainter(progress: progress)),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKey.dailyGoal.tr,
              style: TextStyle(color: TColor.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: onTap,
              child: Text(
                '$totalMl/${goalMl}ml',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_drink, color: TColor.white, size: 24),
                const SizedBox(width: 10),
                Icon(Icons.wb_sunny_outlined, color: TColor.white, size: 24),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
