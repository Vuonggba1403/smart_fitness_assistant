import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ✨ Service layer để tách business logic ra khỏi Cubit
class WaterTrackerService {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  final List<int> _scheduledReminderIds = [];

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ========== Settings Operations ==========

  /// Load water goal settings từ database
  Future<WaterGoalSettings> loadSettings(String userId) async {
    try {
      final response = await _supabase
          .from('water_goal_settings')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (response != null) {
        return WaterGoalSettings.fromJson(response);
      }

      // Tạo settings mặc định nếu chưa có
      final defaultSettings = WaterGoalSettings(
        forUser: userId,
        dailyGoalMl: 2000,
        reminderEnabled: false,
        reminderIntervalMinutes: 60,
        reminderStartTime: const TimeOfDay(hour: 8, minute: 0),
        reminderEndTime: const TimeOfDay(hour: 22, minute: 0),
      );

      await _supabase
          .from('water_goal_settings')
          .insert(defaultSettings.toJson());

      return defaultSettings;
    } catch (e) {
      print('❌ Error loading settings: $e');
      return WaterGoalSettings(forUser: userId);
    }
  }

  /// Update daily goal
  Future<void> updateGoal(String userId, int newGoalMl) async {
    await _supabase.from('water_goal_settings').upsert({
      'for_user': userId,
      'daily_goal_ml': newGoalMl,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'for_user').select();
  }

  /// Update reminder settings
  Future<void> updateReminderSettings(
    String userId,
    WaterGoalSettings settings,
  ) async {
    await _supabase.from('water_goal_settings').upsert({
      'for_user': userId,
      'daily_goal_ml': settings.dailyGoalMl,
      'reminder_enabled': settings.reminderEnabled,
      'reminder_interval_minutes': settings.reminderIntervalMinutes,
      'reminder_start_time': _formatTimeOfDay(settings.reminderStartTime),
      'reminder_end_time': _formatTimeOfDay(settings.reminderEndTime),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'for_user');
  }

  // ========== Water Intake Operations ==========

  /// Load today's water intake records
  Future<List<WaterIntake>> loadTodayIntakes(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('water_intake')
        .select()
        .eq('for_user', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);

    return response.map((json) => WaterIntake.fromJson(json)).toList();
  }

  /// Add water intake record
  Future<void> addWaterIntake(String userId, int amountMl) async {
    final intake = WaterIntake(
      forUser: userId,
      amountMl: amountMl,
      createdAt: DateTime.now(),
    );

    await _supabase.from('water_intake').insert(intake.toJson());
  }

  /// Delete water intake record
  Future<void> deleteWaterIntake(String id) async {
    await _supabase.from('water_intake').delete().eq('id', id);
  }

  // ========== Notification Operations ==========

  /// Schedule water reminders based on settings
  Future<void> scheduleReminders(
    String userId,
    WaterGoalSettings settings,
  ) async {
    if (!settings.reminderEnabled) {
      print('⚠️ Reminders disabled');
      return;
    }

    print('📅 Starting to schedule water reminders...');

    // Cancel existing reminders trước
    await cancelReminders(userId);

    final startTime =
        settings.reminderStartTime ?? const TimeOfDay(hour: 8, minute: 0);
    final endTime =
        settings.reminderEndTime ?? const TimeOfDay(hour: 22, minute: 0);
    final intervalMinutes = settings.reminderIntervalMinutes;

    print('⚙️ Settings:');
    print('   Start: ${startTime.hour}:${startTime.minute}');
    print('   End: ${endTime.hour}:${endTime.minute}');
    print('   Interval: $intervalMinutes min');

    final now = DateTime.now();

    // Tạo DateTime cho startTime và endTime
    var startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    // ✨ FIX: Nếu endTime đã qua hôm nay, schedule cho ngày mai
    if (endDateTime.isBefore(now)) {
      print('⏭️ End time passed today, scheduling for tomorrow');
      startDateTime = startDateTime.add(const Duration(days: 1));
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    var nextReminder = startDateTime;

    // Nếu startTime đã qua nhưng vẫn trong khoảng thời gian hôm nay
    if (nextReminder.isBefore(now) && endDateTime.isAfter(now)) {
      final minutesSinceStart = now.difference(nextReminder).inMinutes;
      final intervalsPassed = (minutesSinceStart / intervalMinutes).ceil();
      nextReminder = nextReminder.add(
        Duration(minutes: intervalsPassed * intervalMinutes),
      );
      print('⏭️ Start time passed, next reminder at: $nextReminder');
    }

    _scheduledReminderIds.clear();
    int scheduledCount = 0;

    // Schedule multiple reminders trong ngày
    while (nextReminder.isBefore(endDateTime) ||
        nextReminder.isAtSameMomentAs(endDateTime)) {
      if (nextReminder.isAfter(now)) {
        final reminderId = _generateReminderId(userId, nextReminder);
        _scheduledReminderIds.add(reminderId);

        await _notificationService.scheduleWorkoutNotification(
          id: reminderId,
          title: '💧 Đã đến giờ uống nước!',
          body: 'Hãy uống nước để giữ sức khỏe nhé! 🥤',
          scheduledTime: nextReminder,
        );

        scheduledCount++;
        print(
          '✅ Scheduled reminder #$scheduledCount at: ${nextReminder.hour}:${nextReminder.minute.toString().padLeft(2, '0')}',
        );
      }

      nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));

      // Safety check: tránh infinite loop
      if (scheduledCount > 50) {
        print('⚠️ Too many reminders, stopping at $scheduledCount');
        break;
      }
    }

    print('✅ Total scheduled: ${_scheduledReminderIds.length} water reminders');
    print('📊 Reminder IDs: $_scheduledReminderIds');
  }

  /// Cancel all scheduled water reminders
  Future<void> cancelReminders(String userId) async {
    try {
      for (final reminderId in _scheduledReminderIds) {
        await _notificationService.cancelNotification(reminderId);
      }
      _scheduledReminderIds.clear();
    } catch (e) {
      print('❌ Error cancelling reminders: $e');
    }
  }

  /// Get pending notifications (for debug)
  Future<List<dynamic>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }

  // ========== Utility Methods ==========

  /// Calculate total water intake in ml
  int calculateTotalMl(List<WaterIntake> intakes) {
    return intakes.fold<int>(0, (sum, intake) => sum + intake.amountMl);
  }

  /// Format next reminder time
  String getNextReminderText(WaterGoalSettings settings) {
    if (!settings.reminderEnabled) {
      return 'Reminders disabled';
    }

    final now = DateTime.now();
    final startTime =
        settings.reminderStartTime ?? const TimeOfDay(hour: 8, minute: 0);
    final endTime =
        settings.reminderEndTime ?? const TimeOfDay(hour: 22, minute: 0);

    var nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    // Nếu end time đã qua, reminder sẽ là ngày mai
    if (endDateTime.isBefore(now)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
      return 'Tomorrow ${_formatDateTime(nextReminder)}';
    }

    // Nếu start time đã qua nhưng vẫn trong khoảng thời gian hôm nay
    if (nextReminder.isBefore(now) && endDateTime.isAfter(now)) {
      final intervalMinutes = settings.reminderIntervalMinutes;
      final minutesSinceStart = now.difference(nextReminder).inMinutes;
      final intervalsPassed = (minutesSinceStart / intervalMinutes).ceil();
      nextReminder = nextReminder.add(
        Duration(minutes: intervalsPassed * intervalMinutes),
      );

      if (nextReminder.isAfter(endDateTime)) {
        // Reminder tiếp theo sẽ là ngày mai
        nextReminder = DateTime(
          now.year,
          now.month,
          now.day + 1,
          startTime.hour,
          startTime.minute,
        );
        return 'Tomorrow ${_formatDateTime(nextReminder)}';
      }
      return _formatDateTime(nextReminder);
    }

    // Start time chưa đến
    if (nextReminder.isAfter(now)) {
      return _formatDateTime(nextReminder);
    }

    // Fallback: ngày mai
    final tomorrow = nextReminder.add(const Duration(days: 1));
    return 'Tomorrow ${_formatDateTime(tomorrow)}';
  }

  // ========== Private Helpers ==========

  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  int _generateReminderId(String userId, DateTime dateTime) {
    final userHash = userId.hashCode.abs() % 10000;
    final timeComponent = dateTime.hour * 100 + dateTime.minute;
    return 100000 + userHash + timeComponent;
  }
}
