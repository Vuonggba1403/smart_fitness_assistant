import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';

part 'meal_planner_state.dart';

class MealPlannerCubit extends Cubit<MealPlannerState> {
  final _supabase = Supabase.instance.client;

  MealPlannerCubit() : super(MealPlannerInitial());

  /// ⏱ DateTime hiện tại
  DateTime _selectedDateTime = DateTime.now();

  DateTime get selectedDateTime => _selectedDateTime;

  /// 🔄 UPDATE DATE TIME
  void updateDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    emit(DateTimeUpdated(dateTime));
  }

  /// ✅ Lưu activity factor
  double currentActivityFactor = 1.55;

  /// ✅ Check nếu user đã có activity preference
  Future<bool> checkActivityPreference() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existing = await _supabase
          .from('user_activity_preferences')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (existing != null) {
        final factor = existing['activity_factor'] as double? ?? 1.55;
        currentActivityFactor = factor;
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking preference: $e');
      return false;
    }
  }

  /// ✅ Load activity levels từ Supabase
  Future<void> loadActivityLevels() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      final hasPreference = await checkActivityPreference();
      if (hasPreference) {
        return;
      }

      emit(MealPlannerLoading());

      final response = await _supabase
          .from('activity_levels')
          .select()
          .order('number', ascending: true);

      if (response == null || (response as List).isEmpty) {
        emit(MealPlannerError('Không có dữ liệu mức độ hoạt động'));
        return;
      }

      final levels = (response as List)
          .map((json) {
            try {
              return ActivityLevel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('❌ Lỗi parse activity level: $e');
              return null;
            }
          })
          .whereType<ActivityLevel>()
          .toList();

      if (levels.isEmpty) {
        emit(MealPlannerError('Lỗi load dữ liệu mức độ hoạt động'));
        return;
      }

      emit(ActivityLevelsLoaded(levels));
    } catch (e) {
      emit(MealPlannerError('Error loading activity levels: ${e.toString()}'));
      print('❌ Error loading activity levels: $e');
    }
  }

  /// ✅ Save activity preference to database
  Future<void> saveActivityPreference(
    String activityLevelId,
    int dailyCalories,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      final activityFactorMap = {
        'sedentary': 1.2,
        'lightly_active': 1.375,
        'moderately_active': 1.55,
        'very_active': 1.725,
        'extremely_active': 1.9,
      };

      final factor = activityFactorMap[activityLevelId] ?? 1.55;
      currentActivityFactor = factor;

      final existing = await _supabase
          .from('user_activity_preferences')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('user_activity_preferences')
            .update({
              'for_activity_level': activityLevelId,
              'daily_calorie_target': dailyCalories,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('for_user', userId);
      } else {
        await _supabase.from('user_activity_preferences').insert({
          'for_user': userId,
          'for_activity_level': activityLevelId,
          'daily_calorie_target': dailyCalories,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      emit(ActivityPreferenceSaved(activityLevelId, dailyCalories));
    } catch (e) {
      emit(MealPlannerError('Error saving activity preference: $e'));
    }
  }

  /// Load meals by date
  Future<void> loadMealsByDate(DateTime date) async {
    try {
      _selectedDateTime = date;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // ✅ Get target calories
      final pref = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      int targetCalories = pref?['daily_calorie_target'] ?? 2000;

      // ✅ Load meals grouped by type
      final mealsByType = await loadMealsByDateAndType(date);
      final currentCalories = _calculateTotalCalories(mealsByType);

      // ✅ Emit loaded state with meals data
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

  /// ➕ ADD MEAL TO TYPE
  Future<void> addMealToType(String mealType, Map meal, DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // 💾 Save meal to database
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

      // ✅ Emit success state
      emit(
        MealAdded(
          mealType: mealType,
          mealName: meal['name'],
          calories: meal['calories'] ?? 0,
          dateTime: date,
        ),
      );

      // 🔄 Load meals ngay sau khi thêm
      await Future.delayed(const Duration(milliseconds: 300));
      final mealsByType = await loadMealsByDateAndType(date);

      // ✅ Emit state mới với dữ liệu meals đã update
      emit(
        MealsLoaded(
          breakfast: mealsByType['breakfast'] ?? [],
          lunch: mealsByType['lunch'] ?? [],
          dinner: mealsByType['dinner'] ?? [],
          currentCalories: _calculateTotalCalories(mealsByType),
          targetCalories: 2000,
          selectedDateTime: date,
        ),
      );
    } catch (e) {
      emit(MealPlannerError('Error adding meal: ${e.toString()}'));
      print('❌ Error adding meal: $e');
    }
  }

  /// 🧮 Calculate total calories
  int _calculateTotalCalories(Map<String, List<Map>> mealsByType) {
    int total = 0;
    mealsByType.forEach((key, meals) {
      for (var meal in meals) {
        total += (meal['calories'] as int? ?? 0);
      }
    });
    return total;
  }

  /// 📥 LOAD MEALS BY DATE AND TYPE
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
          .eq('for_user', userId) // ✅ Đúng với tên cột
          .eq('meal_date', dateStr);

      if (response == null || (response as List).isEmpty) {
        return {'breakfast': [], 'lunch': [], 'dinner': []};
      }

      // Group by meal_type
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
      print('Error loading meals by type: $e');
      return {'breakfast': [], 'lunch': [], 'dinner': []};
    }
  }

  /// 🗑️ REMOVE MEAL
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

      // ✅ Load meals ngay sau khi xóa để update calories
      await loadMealsByDate(_selectedDateTime);
    } catch (e) {
      emit(MealPlannerError('Error removing meal: ${e.toString()}'));
    }
  }

  /// 🔍 SEARCH MEALS
  Future<List<Meal>> searchMeals(String query) async {
    try {
      if (query.isEmpty) return [];

      final response = await _supabase
          .from('meals')
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  /// 📥 GET ALL MEALS (for recent tab)
  Future<List<Meal>> getAllMeals() async {
    try {
      final response = await _supabase.from('meals').select().limit(50);

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading meals: $e');
      return [];
    }
  }
}
