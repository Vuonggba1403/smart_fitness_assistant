import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';

class WaterTrackerHelper {
  /// Tính next reminder time
  static String getNextReminderText(WaterGoalSettings settings) {
    final now = DateTime.now();
    final startTime =
        settings.reminderStartTime ?? const TimeOfDay(hour: 8, minute: 0);

    final nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    if (nextReminder.isAfter(now)) {
      return _formatTime(nextReminder);
    } else {
      final tomorrow = nextReminder.add(const Duration(days: 1));
      return 'Tomorrow ${_formatTime(tomorrow)}';
    }
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
