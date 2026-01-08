import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._notificationService) : super(ScheduleInitial());

  final _supabase = Supabase.instance.client;
  final NotificationService _notificationService;

  /// Cache categories để tránh query nhiều lần
  List<ExerciseCategory>? _cachedCategories;

  /// Load danh sách categories
  Future<void> loadCategories() async {
    if (_cachedCategories != null) {
      emit(CategoriesLoaded(_cachedCategories!));
      return;
    }

    emit(CategoriesLoading());

    try {
      final response = await _supabase
          .from('exercise_categories')
          .select()
          .order('title_ex');

      _cachedCategories = response
          .map((json) => ExerciseCategory.fromJson(json))
          .toList();

      emit(CategoriesLoaded(_cachedCategories!));
    } catch (e) {
      emit(ScheduleError('Failed to load categories: ${e.toString()}'));
    }
  }

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
              title_ex_en,
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
      final response = await _supabase
          .from('scheduled_workouts')
          .insert(schedule.toJson())
          .select()
          .single();

      // ✅ Schedule notification nếu được bật
      if (schedule.hasNotification) {
        final scheduleId = response['id'] as String;
        final categoryName = await _getCategoryName(schedule.categoryId);

        await _notificationService.scheduleWorkoutNotification(
          id: scheduleId.hashCode,
          title: 'Workout Reminder',
          body: 'Time for $categoryName workout!',
          scheduledTime: schedule.scheduledTime,
        );

        print(
          '✅ Notification scheduled for $categoryName at ${schedule.scheduledTime}',
        );
      }

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

  /// Lấy category name từ cache hoặc database
  Future<String> _getCategoryName(String categoryId) async {
    if (_cachedCategories != null) {
      final category = _cachedCategories!.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => const ExerciseCategory(),
      );
      return category.titleEx ?? 'Workout';
    }

    try {
      final response = await _supabase
          .from('exercise_categories')
          .select('title_ex, title_ex_en')
          .eq('id', categoryId)
          .single();
      final category = ExerciseCategory.fromJson(response);
      return category.localizedTitleEx;
    } catch (e) {
      return 'Workout';
    }
  }

  /// Xóa lịch tập - ✅ FIX: Cancel notification và reload data
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      // ✅ Cancel notification trước khi xóa
      await _notificationService.cancelNotification(scheduleId.hashCode);

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

  /// Đánh dấu hoàn thành - ✅ FIX: Cancel notification và reload data
  Future<bool> markScheduleAsCompleted(String scheduleId) async {
    try {
      // ✅ Cancel notification khi complete
      await _notificationService.cancelNotification(scheduleId.hashCode);

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
