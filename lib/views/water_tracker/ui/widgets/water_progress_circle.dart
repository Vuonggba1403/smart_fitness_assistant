import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'dart:math' as math;

/// ✨ Gộp WaterProgressPainter + WaterProgressDisplay thành 1 file
class WaterProgressCircle extends StatelessWidget {
  final int totalMl;
  final int goalMl;
  final double progress;
  final VoidCallback onTap;

  const WaterProgressCircle({
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
          child: CustomPaint(
            painter: _WaterProgressPainter(progress: progress),
          ),
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

// ========== Private Painter ==========

class _WaterProgressPainter extends CustomPainter {
  final double progress;

  _WaterProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = TColor.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = TColor.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_WaterProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
