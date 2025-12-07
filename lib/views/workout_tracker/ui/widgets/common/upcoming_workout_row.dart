import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';

class UpcomingWorkoutRow extends StatelessWidget {
  final UpcomingWorkout workout;
  final Function(bool)? onNotificationToggle;

  const UpcomingWorkoutRow({
    super.key,
    required this.workout,
    this.onNotificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    final completionPercent = workout.totalExercises > 0
        ? workout.completedExercises / workout.totalExercises
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình ảnh workout
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: workout.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: CustomCircleProgIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.fitness_center),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Thông tin workout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên category
                Text(
                  workout.categoryName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Thời gian
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: textColor?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatScheduledTime(workout.scheduledTime),
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ Số bài đã tập / chưa tập
                Text(
                  '${workout.completedExercises}/${workout.totalExercises} bài tập',
                  style: TextStyle(
                    color: textColor?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Nút toggle notification
          Switch(
            value: workout.isNotificationEnabled,
            onChanged: (enabled) async {
              // ✅ GỌI callback NGAY LẬP TỨC để cập nhật UI
              onNotificationToggle?.call(enabled);
            },
            activeColor: TColor.primaryColor1,
          ),
        ],
      ),
    );
  }

  String _formatScheduledTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(time.year, time.month, time.day);

    // ✅ Format giờ:phút
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    if (scheduledDate == today) {
      return 'Hôm nay, $timeStr';
    } else if (scheduledDate == today.add(const Duration(days: 1))) {
      return 'Ngày mai, $timeStr';
    } else {
      // ✅ Format: dd/MM, HH:mm
      final day = time.day.toString().padLeft(2, '0');
      final month = time.month.toString().padLeft(2, '0');
      return '$day/$month, $timeStr';
    }
  }
}
