import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  ScheduleCubit() : super(ScheduleInitial());

  /// Load lịch tập theo ngày
  Future<void> loadSchedulesByDate(DateTime date) async {
    emit(ScheduleLoading());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ScheduleError('User not authenticated'));
        return;
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

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

  /// Thêm lịch tập mới
  Future<bool> addSchedule(ScheduledWorkout schedule) async {
    try {
      final response = await _supabase
          .from('scheduled_workouts')
          .insert(schedule.toJson())
          .select()
          .single();

      final newSchedule = ScheduledWorkout.fromJson(response);

      // ✅ Lên lịch notification nếu cần
      if (schedule.hasNotification) {
        await _scheduleNotification(newSchedule);
      }

      // Reload lại list
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error adding schedule: $e');
      return false;
    }
  }

  /// Xóa lịch tập
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase.from('scheduled_workouts').delete().eq('id', scheduleId);

      // ✅ Hủy notification
      await _notificationService.cancelNotification(scheduleId.hashCode);

      // Reload
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  /// Cập nhật lịch tập
  Future<bool> updateSchedule(ScheduledWorkout schedule) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update(schedule.toJson())
          .eq('id', schedule.id!);

      // ✅ Cập nhật notification
      await _notificationService.cancelNotification(schedule.id.hashCode);

      if (schedule.hasNotification && !schedule.isCompleted) {
        await _scheduleNotification(schedule);
      }

      // Reload
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error updating schedule: $e');
      return false;
    }
  }

  /// Đánh dấu hoàn thành
  Future<bool> markAsCompleted(String scheduleId) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update({'is_completed': true})
          .eq('id', scheduleId);

      // Hủy notification
      await _notificationService.cancelNotification(scheduleId.hashCode);

      // Reload
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error marking completed: $e');
      return false;
    }
  }

  /// Toggle notification
  Future<bool> toggleNotification(ScheduledWorkout schedule) async {
    try {
      final newValue = !schedule.hasNotification;

      await _supabase
          .from('scheduled_workouts')
          .update({'has_notification': newValue})
          .eq('id', schedule.id!);

      if (newValue) {
        await _scheduleNotification(schedule.copyWith(hasNotification: true));
      } else {
        await _notificationService.cancelNotification(schedule.id.hashCode);
      }

      // Reload
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        await loadSchedulesByDate(currentState.selectedDate);
      }

      return true;
    } catch (e) {
      print('❌ Error toggling notification: $e');
      return false;
    }
  }

  /// Private: Lên lịch notification
  Future<void> _scheduleNotification(ScheduledWorkout schedule) async {
    await _notificationService.scheduleWorkoutNotification(
      id: schedule.id.hashCode,
      title: '⏰ Đã đến giờ tập luyện!',
      body: '${schedule.categoryName} - Bắt đầu ngay thôi! 💪',
      scheduledTime: schedule.scheduledTime,
    );
  }
}
