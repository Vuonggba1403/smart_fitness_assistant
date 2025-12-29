import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/upcoming_workout.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Widget hiển thị upcoming workout với notification toggle và delete
class UpcomingWorkoutRow extends StatelessWidget {
  final UpcomingWorkout workout;
  final Function(bool)? onNotificationToggle;
  final VoidCallback? onDelete;

  const UpcomingWorkoutRow({
    super.key,
    required this.workout,
    this.onNotificationToggle,
    this.onDelete,
  });

  /// Format thời gian scheduled thành text hiển thị
  String _formatScheduledTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(time.year, time.month, time.day);

    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (scheduledDate == today) {
      return 'Hôm nay, $timeStr';
    } else if (scheduledDate == today.add(const Duration(days: 1))) {
      return 'Ngày mai, $timeStr';
    } else {
      final day = time.day.toString().padLeft(2, '0');
      final month = time.month.toString().padLeft(2, '0');
      return '$day/$month, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

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
          _buildWorkoutImage(),
          const SizedBox(width: 15),
          Expanded(child: _buildWorkoutInfo(textColor)),
          _buildActionButtons(cardColor),
        ],
      ),
    );
  }

  /// Build hình ảnh workout
  Widget _buildWorkoutImage() {
    return ClipRRect(
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
    );
  }

  /// Build thông tin workout (tên, thời gian, số exercises)
  Widget _buildWorkoutInfo(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.categoryName,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
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
        Text(
          '${workout.completedExercises}/${workout.totalExercises} ${LocaleKey.exercises.tr}',
          style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  /// Build 2 nút action: Bell (notification) và Trash (delete)
  Widget _buildActionButtons(Color cardColor) {
    return Column(
      children: [
        _buildNotificationButton(cardColor),
        const SizedBox(height: 8),
        _buildDeleteButton(cardColor),
      ],
    );
  }

  /// Build nút toggle notification
  Widget _buildNotificationButton(Color cardColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: workout.isNotificationEnabled
            ? Colors.green.withOpacity(0.2)
            : cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: workout.isNotificationEnabled
              ? Colors.green
              : TColor.gray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          workout.isNotificationEnabled
              ? Icons.notifications_active
              : Icons.notifications_off_outlined,
          color: workout.isNotificationEnabled ? Colors.green : TColor.gray,
          size: 20,
        ),
        onPressed: () {
          onNotificationToggle?.call(!workout.isNotificationEnabled);
        },
      ),
    );
  }

  /// Build nút delete
  Widget _buildDeleteButton(Color cardColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
        onPressed: onDelete,
      ),
    );
  }
}
