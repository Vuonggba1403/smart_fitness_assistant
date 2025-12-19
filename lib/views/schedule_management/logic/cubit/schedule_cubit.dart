import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleInitial());

  final _supabase = Supabase.instance.client;

  /// Tải lịch tập theo ngày - ✅ FIX: Join với exercise_categories
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

      // ✅ FIX: Join với exercise_categories
      final response = await _supabase
          .from('scheduled_workouts')
          .select('''
            *,
            exercise_categories!inner(
              title_ex,
              img_url
            )
          ''')
          .eq('for_user', userId)
          .gte('scheduled_time', startOfDay.toIso8601String())
          .lt('scheduled_time', endOfDay.toIso8601String())
          .order('scheduled_time');

      final schedules = response.map((json) {
        return ScheduledWorkout.fromJson(json);
      }).toList();

      emit(ScheduleLoaded(schedules, date));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  /// Thêm lịch tập mới
  Future<bool> addSchedule(ScheduledWorkout schedule) async {
    try {
      await _supabase.from('scheduled_workouts').insert(schedule.toJson());

      // ✅ FIX: Reload lại schedules của ngày đã add
      final scheduledDate = DateTime(
        schedule.scheduledTime.year,
        schedule.scheduledTime.month,
        schedule.scheduledTime.day,
      );
      await loadSchedulesByDate(scheduledDate);

      return true;
    } catch (e) {
      print('❌ Error adding schedule: $e');
      return false;
    }
  }

  /// Xóa lịch tập - ✅ FIX: Reload data sau khi xóa
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase.from('scheduled_workouts').delete().eq('id', scheduleId);

      // ✅ FIX: Reload lại schedules của ngày hiện tại
      if (state is ScheduleLoaded) {
        final currentDate = (state as ScheduleLoaded).selectedDate;
        await loadSchedulesByDate(currentDate);
      }

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  /// Đánh dấu hoàn thành - ✅ FIX: Reload data sau khi complete
  Future<bool> markScheduleAsCompleted(String scheduleId) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update({'is_completed': true})
          .eq('id', scheduleId);

      // ✅ FIX: Reload lại schedules của ngày hiện tại
      if (state is ScheduleLoaded) {
        final currentDate = (state as ScheduleLoaded).selectedDate;
        await loadSchedulesByDate(currentDate);
      }

      return true;
    } catch (e) {
      print('❌ Error marking schedule as completed: $e');
      return false;
    }
  }
}
