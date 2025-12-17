import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

part 'water_tracker_state.dart';

class WaterTrackerCubit extends Cubit<WaterTrackerState> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  bool _hasShownCongratulations = false;

  // ✅ THÊM: Lưu list reminder IDs đã schedule
  final List<int> _scheduledReminderIds = [];

  WaterTrackerCubit() : super(WaterTrackerInitial()) {
    loadTodayWaterIntake();
  }

  /// Load settings + water intake
  Future<void> loadTodayWaterIntake() async {
    emit(WaterTrackerLoading());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(WaterTrackerError('User not authenticated'));
        return;
      }

      final settings = await _loadSettings(userId);

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

      final intakes = response
          .map((json) => WaterIntake.fromJson(json))
          .toList();
      final totalMl = intakes.fold<int>(
        0,
        (sum, intake) => sum + intake.amountMl,
      );

      if (totalMl < settings.dailyGoalMl) {
        _hasShownCongratulations = false;
      }

      emit(
        WaterTrackerLoaded(
          totalMl: totalMl,
          goalMl: settings.dailyGoalMl,
          intakes: intakes,
          settings: settings,
        ),
      );

      if (settings.reminderEnabled) {
        await _scheduleWaterReminders(settings);
      }
    } catch (e) {
      emit(WaterTrackerError(e.toString()));
    }
  }

  /// Load settings từ DB
  Future<WaterGoalSettings> _loadSettings(String userId) async {
    try {
      final response = await _supabase
          .from('water_goal_settings')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (response != null) {
        return WaterGoalSettings.fromJson(response);
      }

      final defaultSettings = WaterGoalSettings(
        forUser: userId,
        dailyGoalMl: 2000,
        reminderEnabled: false,
        reminderIntervalMinutes: 60,
        reminderStartTime: TimeOfDay(hour: 8, minute: 0),
        reminderEndTime: TimeOfDay(hour: 22, minute: 0),
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

  /// Update goal
  Future<void> updateGoal(int newGoalMl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('🔄 Updating goal to: ${newGoalMl}ml for user: $userId');

      await _supabase.from('water_goal_settings').upsert({
        'for_user': userId,
        'daily_goal_ml': newGoalMl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'for_user').select();

      print('✅ Goal updated successfully');
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating goal: $e');
    }
  }

  /// Update reminder settings
  Future<void> updateReminderSettings(WaterGoalSettings newSettings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('🔄 Updating reminder settings for user: $userId');

      await _supabase.from('water_goal_settings').upsert({
        'for_user': userId,
        'daily_goal_ml': newSettings.dailyGoalMl,
        'reminder_enabled': newSettings.reminderEnabled,
        'reminder_interval_minutes': newSettings.reminderIntervalMinutes,
        'reminder_start_time': _formatTimeOfDay(newSettings.reminderStartTime),
        'reminder_end_time': _formatTimeOfDay(newSettings.reminderEndTime),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'for_user');

      print('✅ Reminder settings updated successfully');
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating reminder: $e');
    }
  }

  /// Helper: Format TimeOfDay to string
  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Schedule water reminders với user-specific ID
  Future<void> _scheduleWaterReminders(WaterGoalSettings settings) async {
    if (!settings.reminderEnabled) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Cancel existing reminders for this user
    await _cancelUserWaterReminders(userId);

    final startTime =
        settings.reminderStartTime ?? TimeOfDay(hour: 8, minute: 0);
    final endTime = settings.reminderEndTime ?? TimeOfDay(hour: 22, minute: 0);
    final intervalMinutes = settings.reminderIntervalMinutes;

    final now = DateTime.now();
    var nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    // ✅ Clear list cũ
    _scheduledReminderIds.clear();

    // Schedule multiple reminders trong ngày
    while (nextReminder.hour < endTime.hour ||
        (nextReminder.hour == endTime.hour &&
            nextReminder.minute <= endTime.minute)) {
      if (nextReminder.isAfter(now)) {
        final reminderId = _generateReminderId(userId, nextReminder);

        // ✅ LƯU ID vào list
        _scheduledReminderIds.add(reminderId);

        await _notificationService.scheduleWorkoutNotification(
          id: reminderId,
          title: '💧 Đã đến giờ uống nước!',
          body: 'Hãy uống nước để giữ sức khỏe nhé! 🥤',
          scheduledTime: nextReminder,
        );

        print('✅ Reminder ID: $reminderId');
      }
      nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));
    }

    print('✅ Total reminders scheduled: ${_scheduledReminderIds.length}');
  }

  /// ✅ Cancel all water reminders for current user - CHỈ cancel những cái thực tế
  Future<void> _cancelUserWaterReminders(String userId) async {
    try {
      // ✅ Chỉ cancel những reminder đã được schedule
      for (final reminderId in _scheduledReminderIds) {
        await _notificationService.cancelNotification(reminderId);
        print('❌ Notification $reminderId cancelled');
      }

      // ✅ Clear list sau khi cancel
      _scheduledReminderIds.clear();

      print(
        '✅ Cancelled ${_scheduledReminderIds.length} water reminders for user: $userId',
      );
    } catch (e) {
      print('❌ Error cancelling reminders: $e');
    }
  }

  /// Thêm lượng nước đã uống
  Future<void> addWaterIntake(int amountMl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final intake = WaterIntake(
        forUser: userId,
        amountMl: amountMl,
        createdAt: DateTime.now(),
      );

      await _supabase.from('water_intake').insert(intake.toJson());
      await loadTodayWaterIntake();

      // Check xem đã đạt goal chưa
      final currentState = state;
      if (currentState is WaterTrackerLoaded) {
        if (currentState.totalMl >= currentState.goalMl &&
            !_hasShownCongratulations) {
          emit(
            WaterGoalAchieved(
              totalMl: currentState.totalMl,
              goalMl: currentState.goalMl,
            ),
          );
          _hasShownCongratulations = true;

          await Future.delayed(const Duration(seconds: 1));
          emit(currentState);
        }
      }
    } catch (e) {
      print('❌ Error adding water intake: $e');
    }
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntake(String id) async {
    try {
      await _supabase.from('water_intake').delete().eq('id', id);
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error deleting water intake: $e');
    }
  }

  /// ✅ Generate user-specific reminder ID
  int _generateReminderId(String userId, DateTime dateTime) {
    final userHash = userId.hashCode.abs() % 10000;
    final timeComponent = dateTime.hour * 100 + dateTime.minute;
    return 100000 + userHash + timeComponent;
  }

  @override
  Future<void> close() async {
    // Cancel all reminders when cubit is closed (logout)
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _cancelUserWaterReminders(userId);
    }
    return super.close();
  }
}
