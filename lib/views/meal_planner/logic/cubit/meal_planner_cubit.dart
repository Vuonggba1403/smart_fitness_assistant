import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';

part 'meal_planner_state.dart';

class MealPlannerCubit extends Cubit<MealPlannerState> {
  final _supabase = Supabase.instance.client;

  MealPlannerCubit() : super(MealPlannerInitial());

  /// ✅ Lưu activity factor
  double currentActivityFactor = 1.55;

  /// ✅ Load activity levels từ Supabase, sắp xếp theo number
  Future<void> loadActivityLevels() async {
    try {
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

  /// ✅ IMPLEMENT: Save activity preference to database
  /// - activityLevelId: UUID string từ Supabase
  /// - dailyCalories: TDEE tính từ BMR × activity_factor
  /// Emit: ActivityPreferenceSaved state để UI cập nhật
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

      // Map activity id to activity factor
      final activityFactorMap = {
        'sedentary': 1.2,
        'lightly_active': 1.375,
        'moderately_active': 1.55,
        'very_active': 1.725,
        'extremely_active': 1.9,
      };

      final factor = activityFactorMap[activityLevelId] ?? 1.55;
      currentActivityFactor = factor;

      // Check if preference already exists
      final existing = await _supabase
          .from('user_activity_preferences')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await _supabase
            .from('user_activity_preferences')
            .update({
              'for_activity_level': activityLevelId,
              'daily_calorie_target': dailyCalories,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('for_user', userId);
      } else {
        // Insert new
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

  // TODO: Implement when meal_plan_items table is recreated
  Future<void> loadMealsByDate(DateTime date) async {
    try {
      // ✅ Không emit loading, emit MealsLoaded ngay
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // ✅ Lấy TDEE từ user_activity_preferences
      final pref = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      int targetCalories = pref?['daily_calorie_target'] ?? 2000;

      // Placeholder - will implement when tables are recreated
      emit(
        MealsLoaded(
          breakfast: [],
          lunch: [],
          dinner: [],
          currentCalories: 0,
          targetCalories: targetCalories, // ✅ Sử dụng TDEE thực tế
        ),
      );
    } catch (e) {
      emit(MealPlannerError('Error loading meals: ${e.toString()}'));
    }
  }

  // TODO: Implement when meal_plan_items table is recreated
  Future<void> addMealToType(String mealType, Map meal, DateTime date) async {
    try {
      emit(
        MealAdded(
          mealType: mealType,
          message: '${meal['name']} added to $mealType',
        ),
      );
    } catch (e) {
      emit(MealPlannerError('Error adding meal: ${e.toString()}'));
    }
  }

  // TODO: Implement when meal_plan_items table is recreated
  Future<void> removeMealFromType(int mealItemId, DateTime date) async {
    try {
      emit(MealRemoved(''));
    } catch (e) {
      emit(MealPlannerError('Error removing meal: ${e.toString()}'));
    }
  }

  // TODO: Implement when low_calorie_recipes table is recreated
  Future<List<Map>> getAllRecipes() async {
    try {
      return [];
    } catch (e) {
      print('Error loading recipes: $e');
      return [];
    }
  }
}
