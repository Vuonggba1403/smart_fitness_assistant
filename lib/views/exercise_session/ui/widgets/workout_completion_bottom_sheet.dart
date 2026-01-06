import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

class WorkoutCompletionBottomSheet {
  static Future<bool?> show(
    BuildContext context, {
    required int completedSets,
    required int totalSets,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cảnh báo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            Text(
              LocaleKey.finishEarly.tr,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // Thông tin số sets hoàn thành
            Text(
              '${LocaleKey.youCompleted.tr} $completedSets/$totalSets ${LocaleKey.sets.tr}',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Mô tả
            Text(
              LocaleKey.workoutWillBeSaved.tr,
              style: TextStyle(
                color: textColor?.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: TColor.gray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      LocaleKey.continueWorkout.tr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      LocaleKey.finish.tr,
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
