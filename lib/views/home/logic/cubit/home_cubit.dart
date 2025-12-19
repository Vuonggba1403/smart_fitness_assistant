import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final _supabase = Supabase.instance.client;

  HomeCubit() : super(HomeInitial()) {
    _initializeHome();
  }

  void _initializeHome() async {
    // Lấy ngôn ngữ đã lưu
    final savedLanguage = await AppShared.getLanguageCode();

    // Load workout history từ Supabase
    final lastWorkoutArr = await _loadLatestWorkouts();

    emit(
      HomeLoaded(
        showingTooltipOnSpots: [21],
        lastWorkoutArr: lastWorkoutArr,
        currentLanguage: savedLanguage,
      ),
    );
  }

  /// ✅ THÊM: Private helper method - Load latest workouts
  Future<List<Map<String, dynamic>>> _loadLatestWorkouts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // ✅ JOIN với exercise_categories để lấy title_ex + img_url REAL-TIME
      final response = await _supabase
          .from('history_workout')
          .select('''
            id,
            category_id,
            created_at,
            completed_exercises,
            total_exercises,
            exercise_categories!inner(
              title_ex,
              img_url
            )
          ''')
          .eq('for_user', userId)
          .order('created_at', ascending: false)
          .limit(5);

      return response.map<Map<String, dynamic>>((workout) {
        final createdAt = DateTime.parse(workout['created_at']);
        final timeAgo = _formatTimeAgo(createdAt);
        final completed = workout['completed_exercises'] as int;
        final total = workout['total_exercises'] as int;
        final progress = total > 0 ? completed / total : 0.0;

        // ✅ Lấy data từ exercise_categories
        final category = workout['exercise_categories'];
        final categoryName = category['title_ex'] as String;
        final imageUrl =
            category['img_url'] as String? ?? 'assets/img/default_workout.png';

        return {
          'name': categoryName, // ✅ Từ exercise_categories.title_ex
          'image': imageUrl, // ✅ Từ exercise_categories.img_url
          'time_ago': timeAgo,
          'progress': progress,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading latest workouts: $e');
      return [];
    }
  }

  /// ✅ Public method - Load latest workouts (dùng từ HomeView)
  Future<void> loadLatestWorkouts() async {
    try {
      final workouts = await _loadLatestWorkouts();

      // ✅ FIX: Emit với tất cả tham số bắt buộc
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(lastWorkoutArr: workouts));
      } else {
        // ✅ Nếu chưa có state, emit HomeLoaded mới
        emit(HomeLoaded(showingTooltipOnSpots: [21], lastWorkoutArr: workouts));
      }
    } catch (e) {
      print('❌ Error loading latest workouts: $e');
    }
  }

  /// ✅ Format time ago (e.g., "2 giờ trước", "1 ngày trước")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  // ✅ THÊM: Dummy method loadDailyActivity (nếu cần)
  Future<void> loadDailyActivity() async {
    print('📊 HomeCubit: Loading daily activity...');
    try {
      // Force trigger để DailyActivitySection tự refresh
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith()); // Trigger rebuild
      }
      print('✅ HomeCubit: Daily activity loaded');
    } catch (e) {
      print('❌ HomeCubit: Error loading daily activity: $e');
    }
  }

  // Refresh workout history
  Future<void> refreshWorkouts() async {
    if (state is HomeLoaded) {
      final latestWorkouts =
          await _loadLatestWorkouts(); // ✅ Dùng private method
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(lastWorkoutArr: latestWorkouts));
    }
  }

  void updateTooltipSpot(int spotIndex) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(showingTooltipOnSpots: [spotIndex]));
    }
  }

  void refreshUI() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        currentState.copyWith(
          showingTooltipOnSpots: currentState.showingTooltipOnSpots,
          lastWorkoutArr: currentState.lastWorkoutArr,
        ),
      );
    }
  }

  void updateLanguage(String language) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      if (currentState.currentLanguage != language) {
        AppShared.setLanguageCode(language);
        final newState = currentState.copyWith(currentLanguage: language);
        emit(LanguageChanged(language)); // Emit event để trigger dialog
        emit(newState); // Emit lại HomeLoaded để giữ UI
        log('Updating language to: $language');
      }
    }
  }
}
