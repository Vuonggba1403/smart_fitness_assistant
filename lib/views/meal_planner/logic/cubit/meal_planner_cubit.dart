import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:flutter/foundation.dart';

part 'meal_planner_state.dart';

/// 🍽️ Quản lý logic meal planner
class MealPlannerCubit extends Cubit<MealPlannerState> {
  final _supabase = Supabase.instance.client;

  MealPlannerCubit() : super(MealPlannerInitial());

  DateTime _selectedDateTime = DateTime.now();
  DateTime? _lastLoadedDate;

  DateTime get selectedDateTime => _selectedDateTime;

  /// 🔄 Cập nhật date time
  void updateDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    emit(DateTimeUpdated(dateTime));
  }

  /// 🔄 Cập nhật target calories (được gọi từ ActivityLevelDialog)
  Future<void> updateTargetCalories(int dailyCalories) async {
    try {
      // Reload meals với target calories mới
      await loadMealsByDate(_selectedDateTime);
    } catch (e) {
      developer.log('❌ ERROR in updateTargetCalories', error: e);
    }
  }

  /// 🔄 Refresh meals khi quay lại màn hình
  Future<void> refreshMealsByDate(DateTime date) async {
    final now = DateTime.now();

    // Nếu ngày khác, clear cache và reload
    if (_lastLoadedDate?.year != now.year ||
        _lastLoadedDate?.month != now.month ||
        _lastLoadedDate?.day != now.day) {
      _lastLoadedDate = now;
      await loadMealsByDate(now);
    } else {
      await loadMealsByDate(date);
    }
  }

  /// 📥 Load meals theo ngày
  Future<void> loadMealsByDate(DateTime date) async {
    try {
      _selectedDateTime = date;
      _lastLoadedDate = date;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // Lấy target calories từ preferences
      final pref = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      int targetCalories = pref?['daily_calorie_target'] ?? 0;

      // Load meals của ngày
      final mealsByType = await loadMealsByDateAndType(date);
      final currentCalories = _calculateTotalCalories(mealsByType);

      emit(
        MealsLoaded(
          breakfast: mealsByType['breakfast'] ?? [],
          lunch: mealsByType['lunch'] ?? [],
          dinner: mealsByType['dinner'] ?? [],
          currentCalories: currentCalories,
          targetCalories: targetCalories,
          selectedDateTime: date,
        ),
      );
    } catch (e) {
      emit(MealPlannerError('Error loading meals: ${e.toString()}'));
    }
  }

  /// ➕ Thêm meal vào loại bữa ăn
  Future<void> addMealToType(String mealType, Map meal, DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // Lưu meal vào database
      await _supabase.from('user_meals').insert({
        'for_user': userId,
        'for_meal': meal['id'],
        'meal_name': meal['name'],
        'meal_type': mealType,
        'calories': meal['calories'] ?? 0,
        'protein_g': meal['protein'] ?? 0.0,
        'carbs_g': meal['carbs'] ?? 0.0,
        'fat_g': meal['fat'] ?? 0.0,
        'serving_size_g': meal['serving_size'] ?? 100,
        'meal_date': DateFormat('yyyy-MM-dd').format(date),
        'meal_time': DateFormat('HH:mm').format(date),
      });

      // Reload và emit state mới
      await loadMealsByDate(date);

      debugPrint('✅ Meal added: ${meal['name']}');
    } catch (e) {
      emit(MealPlannerError('Error adding meal: ${e.toString()}'));
    }
  }

  /// 🗑️ Xóa meal
  Future<void> removeMeal(String mealId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      await _supabase
          .from('user_meals')
          .delete()
          .eq('id', mealId)
          .eq('for_user', userId);

      // Reload và emit state mới
      await loadMealsByDate(_selectedDateTime);

      debugPrint('✅ Meal removed');
    } catch (e) {
      emit(MealPlannerError('Error removing meal: ${e.toString()}'));
    }
  }

  /// 🔍 Tìm kiếm meals
  Future<List<Meal>> searchMeals(String query) async {
    try {
      if (query.isEmpty) return [];

      final response = await _supabase
          .from('meals')
          .select()
          .ilike('name', '%$query%')
          .eq('is_verified', true)
          .order('name')
          .limit(30);

      if ((response as List).isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching meals: $e');
      return [];
    }
  }

  /// 📥 Lấy tất cả meals (cho tab recent)
  Future<List<Meal>> getAllMeals() async {
    try {
      final response = await _supabase
          .from('meals')
          .select()
          .eq('is_verified', true)
          .order('created_at', ascending: false)
          .limit(50);

      if ((response as List).isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading meals: $e');
      return [];
    }
  }

  /// 📥 Load meals theo ngày và loại
  Future<Map<String, List<Map>>> loadMealsByDateAndType(DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return {};
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final response = await _supabase
          .from('user_meals')
          .select()
          .eq('for_user', userId)
          .eq('meal_date', dateStr)
          .order('meal_time', ascending: true);

      if ((response as List).isEmpty) {
        return {'breakfast': [], 'lunch': [], 'dinner': []};
      }

      // Nhóm meals theo meal_type
      final meals = response as List;
      final groupedMeals = <String, List<Map>>{
        'breakfast': [],
        'lunch': [],
        'dinner': [],
      };

      for (var meal in meals) {
        final mealType = meal['meal_type'] as String;
        if (groupedMeals.containsKey(mealType)) {
          groupedMeals[mealType]!.add(meal as Map);
        }
      }

      return groupedMeals;
    } catch (e) {
      debugPrint('Error loading meals by type: $e');
      return {'breakfast': [], 'lunch': [], 'dinner': []};
    }
  }

  /// 🧮 Tính tổng calories
  int _calculateTotalCalories(Map<String, List<Map>> mealsByType) {
    int total = 0;
    mealsByType.forEach((key, meals) {
      for (var meal in meals) {
        total += (meal['calories'] as int? ?? 0);
      }
    });
    return total;
  }
}
