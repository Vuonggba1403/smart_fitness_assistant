import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import 'package:smart_fitness_assistant/core/models/activity_level.dart';

part 'activity_level_state.dart';

/// 🏋️ Quản lý logic liên quan đến Activity Level
class ActivityLevelCubit extends Cubit<ActivityLevelState> {
  final _supabase = Supabase.instance.client;

  ActivityLevelCubit() : super(ActivityLevelInitial());

  /// 📥 Load danh sách activity levels từ database
  Future<void> loadActivityLevels() async {
    try {
      developer.log('🟢 START: loadActivityLevels', name: 'ActivityLevelCubit');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('❌ User not authenticated', name: 'ActivityLevelCubit');
        emit(ActivityLevelError('User not authenticated'));
        return;
      }

      emit(ActivityLevelLoading());

      // Query activity levels từ database
      final response = await _supabase
          .from('activity_levels')
          .select()
          .order('number', ascending: true);

      if (response == null || (response as List).isEmpty) {
        emit(ActivityLevelError('Không có dữ liệu mức độ hoạt động'));
        return;
      }

      // Parse sang ActivityLevel model
      final levels = (response as List)
          .map((json) => ActivityLevel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (levels.isEmpty) {
        emit(ActivityLevelError('Lỗi load dữ liệu mức độ hoạt động'));
        return;
      }

      emit(ActivityLevelsLoaded(levels));
      developer.log(
        '✅ Loaded ${levels.length} levels',
        name: 'ActivityLevelCubit',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in loadActivityLevels',
        name: 'ActivityLevelCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ActivityLevelError('Error loading activity levels: $e'));
    }
  }

  /// ✅ Kiểm tra xem user đã có preference chưa
  Future<bool> checkActivityPreference() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existing = await _supabase
          .from('user_activity_preferences')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      return existing != null;
    } catch (e) {
      developer.log(
        '❌ ERROR in checkActivityPreference',
        name: 'ActivityLevelCubit',
        error: e,
      );
      return false;
    }
  }

  /// 💾 Lưu activity preference vào database
  Future<void> saveActivityPreference(
    String activityLevelId,
    int dailyCalories,
  ) async {
    try {
      developer.log(
        '🟢 START: saveActivityPreference',
        name: 'ActivityLevelCubit',
      );

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ActivityLevelError('User not authenticated'));
        return;
      }

      // Xóa preferences cũ
      await _supabase
          .from('user_activity_preferences')
          .delete()
          .eq('for_user', userId);

      // Insert preference mới
      final insertData = {
        'for_user': userId,
        'for_activity_level': activityLevelId,
        'daily_calorie_target': dailyCalories,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_activity_preferences').insert(insertData);

      emit(ActivityPreferenceSaved(activityLevelId, dailyCalories));

      developer.log('✅ Saved successfully', name: 'ActivityLevelCubit');
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in saveActivityPreference',
        name: 'ActivityLevelCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ActivityLevelError('Error saving activity preference: $e'));
      rethrow;
    }
  }

  /// 📊 Lấy activity factor từ activity level ID
  Future<double> getActivityFactor(String activityLevelId) async {
    try {
      final level = await _supabase
          .from('activity_levels')
          .select('activity_factor')
          .eq('id', activityLevelId)
          .single();

      return level['activity_factor'] as double? ?? 1.55;
    } catch (e) {
      developer.log(
        '⚠️ Failed to load activity_factor, using default',
        name: 'ActivityLevelCubit',
      );
      return 1.55;
    }
  }
}
