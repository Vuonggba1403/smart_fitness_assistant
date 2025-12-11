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

  // Load 3 workout gần nhất từ history_workout
  Future<List<Map<String, dynamic>>> _loadLatestWorkouts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('history_workout')
          .select(
            'category_id, category_name, completed_exercises, total_exercises, duration_seconds, created_at',
          )
          .eq('for_user', userId)
          .order('created_at', ascending: false)
          .limit(3);

      print('📦 Latest workouts: ${response.length} records');

      // ✅ Load thêm category image từ exercise_categories
      final List<Map<String, dynamic>> workouts = [];

      for (var workout in response) {
        final categoryId = workout['category_id'];

        // ✅ Lấy ảnh từ bảng exercise_categories
        String imageUrl = 'assets/img/Workout1.png'; // Default fallback

        try {
          final categoryResponse = await _supabase
              .from('exercise_categories')
              .select('img_url')
              .eq('id', categoryId)
              .maybeSingle();

          if (categoryResponse != null && categoryResponse['img_url'] != null) {
            imageUrl = categoryResponse['img_url'];
          }
        } catch (e) {
          print('⚠️ Failed to load category image for $categoryId');
        }

        final completed = workout['completed_exercises'] ?? 0;
        final total = workout['total_exercises'] ?? 1;
        final progress = total > 0 ? (completed / total).toDouble() : 0.0;

        // ✅ Tính thời gian tương đối từ created_at
        final createdAt = DateTime.parse(workout['created_at']);
        final timeAgo = _formatTimeAgo(createdAt);

        // Thời lượng tập (phút)
        final durationMinutes = ((workout['duration_seconds'] ?? 0) / 60)
            .round();

        workouts.add({
          "name": workout['category_name'] ?? 'Workout',
          "image": imageUrl, // ✅ Ảnh thực tế từ category
          "time_ago": timeAgo,
          "time": durationMinutes.toString(),
          "progress": progress,
          "created_at": workout['created_at'],
          "category_id": categoryId, // ✅ Lưu thêm category_id để debug
        });
      }

      return workouts;
    } catch (e) {
      print('❌ Error loading latest workouts: $e');
      return [];
    }
  }

  // ✅ Format thời gian tương đối
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes phút trước';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours giờ trước';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ngày trước';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    }
  }

  // Refresh workout history
  Future<void> refreshWorkouts() async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final latestWorkouts = await _loadLatestWorkouts();

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
