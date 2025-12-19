import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

part 'schedule_state.dart';

/// Cubit quản lý lịch tập luyện
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleInitial());

  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  final Map<String, int> _scheduledWorkoutReminderIds = {};

  /// Tải danh sách lịch tập theo ngày
  Future<void> loadSchedulesByDate(DateTime date) async {
    emit(ScheduleLoading());

    try {
      final userId = _getUserId();
      if (userId == null) {
        emit(ScheduleError('User not authenticated'));
        return;
      }

      final (startOfDay, endOfDay) = _getDateRange(date);

      final response = await _supabase
          .from('scheduled_workouts')
          .select()
          .eq('for_user', userId)
          .gte('scheduled_time', startOfDay.toIso8601String())
          .lt('scheduled_time', endOfDay.toIso8601String())
          .order('scheduled_time');

      final schedules = response
          .map((json) => ScheduledWorkout.fromJson(json))
          .toList();

      emit(ScheduleLoaded(schedules, date));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  /// Thêm lịch tập mới - ✅ FIX: Reload ngay sau khi thêm
  Future<bool> addSchedule(ScheduledWorkout schedule) async {
    try {
      final response = await _supabase
          .from('scheduled_workouts')
          .insert(schedule.toJson())
          .select()
          .single();

      final newSchedule = ScheduledWorkout.fromJson(response);

      if (schedule.hasNotification) {
        await _scheduleNotification(newSchedule);
      }

      // ✅ FIX: Reload ngay lập tức
      await _reloadCurrentScheduleDate();

      return true;
    } catch (e) {
      print('❌ Error adding schedule: $e');
      return false;
    }
  }

  /// Xóa lịch tập - ✅ FIX: Reload ngay sau khi xóa
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase.from('scheduled_workouts').delete().eq('id', scheduleId);
      await _notificationService.cancelNotification(scheduleId.hashCode);

      // ✅ FIX: Reload ngay lập tức
      await _reloadCurrentScheduleDate();

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  /// Đánh dấu hoàn thành lịch tập - ✅ FIX: Reload ngay sau khi mark
  Future<bool> markScheduleAsCompleted(String scheduleId) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update({'is_completed': true})
          .eq('id', scheduleId);

      await _notificationService.cancelNotification(scheduleId.hashCode);

      // ✅ FIX: Reload ngay lập tức
      await _reloadCurrentScheduleDate();

      return true;
    } catch (e) {
      print('❌ Error marking completed: $e');
      return false;
    }
  }

  // ============ Private Helpers ============

  String? _getUserId() => _supabase.auth.currentUser?.id;

  (DateTime, DateTime) _getDateRange(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (startOfDay, endOfDay);
  }

  Future<void> _reloadCurrentScheduleDate() async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      await loadSchedulesByDate(currentState.selectedDate);
    }
  }

  Future<void> _scheduleNotification(ScheduledWorkout schedule) async {
    final userId = _getUserId();
    if (userId == null) return;

    final notificationId = _generateWorkoutNotificationId(userId, schedule.id!);
    _scheduledWorkoutReminderIds[schedule.id!] = notificationId;

    await _notificationService.scheduleWorkoutNotification(
      id: notificationId,
      title: '⏰ Đã đến giờ tập luyện!',
      body: '${schedule.categoryName} - Bắt đầu ngay thôi! 💪',
      scheduledTime: schedule.scheduledTime,
    );
  }

  int _generateWorkoutNotificationId(String userId, String scheduleId) {
    final userHash = userId.hashCode.abs() % 10000;
    final scheduleHash = scheduleId.hashCode.abs() % 10000;
    return 200000 + userHash + scheduleHash;
  }

  @override
  Future<void> close() async {
    final userId = _getUserId();
    if (userId != null) {
      await _cancelUserWorkoutReminders(userId);
    }
    return super.close();
  }

  Future<void> _cancelUserWorkoutReminders(String userId) async {
    try {
      for (final scheduleId in _scheduledWorkoutReminderIds.keys) {
        final notificationId = _scheduledWorkoutReminderIds[scheduleId]!;
        await _notificationService.cancelNotification(notificationId);
      }
      _scheduledWorkoutReminderIds.clear();
    } catch (e) {
      print('❌ Error cancelling workout reminders: $e');
    }
  }
}
