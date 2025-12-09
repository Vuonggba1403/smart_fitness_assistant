import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

part 'water_tracker_state.dart';

class WaterTrackerCubit extends Cubit<WaterTrackerState> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  bool _hasShownCongratulations = false; // ✅ Track đã show congratulations chưa

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

      // Load settings
      final settings = await _loadSettings(userId);

      // Load water intake
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

      // ✅ Reset flag nếu chưa đạt goal
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

      // Schedule reminders nếu enabled
      if (settings.reminderEnabled) {
        await _scheduleWaterReminders(settings);
      }
    } catch (e) {
      emit(WaterTrackerError(e.toString()));
    }
  }

  /// ✅ Load settings từ DB
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

  /// ✅ Update goal
  Future<void> updateGoal(int newGoalMl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('🔄 Updating goal to: ${newGoalMl}ml for user: $userId');

      // ✅ Upsert với conflict resolution
      final response = await _supabase.from('water_goal_settings').upsert(
        {
          'for_user': userId,
          'daily_goal_ml': newGoalMl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'for_user', // ✅ QUAN TRỌNG: Conflict trên for_user
      ).select();

      print('✅ Goal updated successfully: $response');

      // ✅ Reload để cập nhật UI
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating goal: $e');
    }
  }

  /// ✅ Update reminder settings - FIX duplicate key error
  Future<void> updateReminderSettings(WaterGoalSettings newSettings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('🔄 Updating reminder settings for user: $userId');

      // ✅ FIX: Upsert với onConflict
      await _supabase.from('water_goal_settings').upsert(
        {
          'for_user': userId,
          'daily_goal_ml': newSettings.dailyGoalMl,
          'reminder_enabled': newSettings.reminderEnabled,
          'reminder_interval_minutes': newSettings.reminderIntervalMinutes,
          'reminder_start_time': _formatTimeOfDay(
            newSettings.reminderStartTime,
          ),
          'reminder_end_time': _formatTimeOfDay(newSettings.reminderEndTime),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'for_user', // ✅ QUAN TRỌNG: Conflict resolution
      );

      print('✅ Reminder settings updated successfully');

      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating reminder: $e');
    }
  }

  /// ✅ Helper: Format TimeOfDay to string
  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// ✅ Schedule water reminders
  Future<void> _scheduleWaterReminders(WaterGoalSettings settings) async {
    if (!settings.reminderEnabled) return;

    // Cancel existing reminders
    await _notificationService.cancelNotification(999);

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

    // Schedule multiple reminders trong ngày
    while (nextReminder.hour < endTime.hour ||
        (nextReminder.hour == endTime.hour &&
            nextReminder.minute <= endTime.minute)) {
      if (nextReminder.isAfter(now)) {
        await _notificationService.scheduleWorkoutNotification(
          id: 999 + nextReminder.hour * 60 + nextReminder.minute,
          title: '💧 Đã đến giờ uống nước!',
          body: 'Hãy uống nước để giữ sức khỏe nhé! 🥤',
          scheduledTime: nextReminder,
        );
      }

      nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));
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

      // Reload
      await loadTodayWaterIntake();

      // ✅ Check xem đã đạt goal chưa
      final currentState = state;
      if (currentState is WaterTrackerLoaded) {
        if (currentState.totalMl >= currentState.goalMl &&
            !_hasShownCongratulations) {
          // ✅ Emit state để trigger congratulations
          emit(
            WaterGoalAchieved(
              totalMl: currentState.totalMl,
              goalMl: currentState.goalMl,
            ),
          );
          _hasShownCongratulations = true;

          // ✅ Sau 1 giây, emit lại WaterTrackerLoaded
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
}
