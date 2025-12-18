import 'dart:developer' as developer; // ✅ THÊM
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:flutter/foundation.dart'; // ✅ THÊM import cho debugPrint

part 'meal_planner_state.dart';

class MealPlannerCubit extends Cubit<MealPlannerState> {
  final _supabase = Supabase.instance.client;

  MealPlannerCubit() : super(MealPlannerInitial());

  /// ⏱ DateTime hiện tại
  DateTime _selectedDateTime = DateTime.now();

  // ✅ THÊM: Track ngày lần cuối load để reset qua ngày
  DateTime? _lastLoadedDate;

  DateTime get selectedDateTime => _selectedDateTime;

  /// 🔄 UPDATE DATE TIME
  void updateDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    emit(DateTimeUpdated(dateTime));
  }

  /// ✅ Lưu activity factor
  double currentActivityFactor = 1.55;

  /// ✅ Save activity preference to database
  Future<void> saveActivityPreference(
    String activityLevelId,
    int dailyCalories,
  ) async {
    try {
      developer.log(
        '🟢 START: saveActivityPreference',
        name: 'MealPlannerCubit',
      );

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // ✅ XÓA: Map activity_factor (không cần nữa)
      // final activityFactorMap = { ... };
      // final factor = activityFactorMap[activityLevelId] ?? 1.55;

      // ✅ Xóa preferences cũ
      await _supabase
          .from('user_activity_preferences')
          .delete()
          .eq('for_user', userId);

      // ✅ INSERT: KHÔNG CÓ activity_factor column
      final insertData = {
        'for_user': userId,
        'for_activity_level': activityLevelId,
        'daily_calorie_target': dailyCalories,
        // ✅ XÓA: 'activity_factor': factor,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_activity_preferences').insert(insertData);

      // ✅ Load activity_factor từ activity_levels
      await _loadCurrentActivityFactor(activityLevelId);

      await loadMealsByDate(_selectedDateTime);

      debugPrint('✅ Activity preference saved successfully');
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in saveActivityPreference',
        name: 'MealPlannerCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(MealPlannerError('Error saving activity preference: $e'));
      rethrow;
    }
  }

  /// ✅ THÊM: Helper method để load activity_factor từ activity_levels
  Future<void> _loadCurrentActivityFactor(String activityLevelId) async {
    try {
      final level = await _supabase
          .from('activity_levels')
          .select('activity_factor')
          .eq('id', activityLevelId)
          .single();

      currentActivityFactor = level['activity_factor'] as double? ?? 1.55;
    } catch (e) {
      developer.log(
        '⚠️ Failed to load activity_factor, using default',
        name: 'MealPlannerCubit',
      );
      currentActivityFactor = 1.55;
    }
  }

  /// ✅ Load activity levels từ Supabase
  Future<void> loadActivityLevels() async {
    try {
      developer.log('🟢 START: loadActivityLevels', name: 'MealPlannerCubit');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('❌ User not authenticated', name: 'MealPlannerCubit');
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      developer.log('User ID: $userId', name: 'MealPlannerCubit');

      // ✅ CHECK: Có preference chưa
      developer.log(
        '🔍 Checking existing preference',
        name: 'MealPlannerCubit',
      );
      final hasPreference = await checkActivityPreference();

      developer.log('Has preference: $hasPreference', name: 'MealPlannerCubit');

      if (hasPreference) {
        developer.log(
          '✅ User has preference, skip dialog',
          name: 'MealPlannerCubit',
        );
        return; // ✅ KHÔNG emit state → dialog không hiện
      }

      // ✅ Emit loading TRƯỚC KHI query
      developer.log('⏳ Emitting MealPlannerLoading', name: 'MealPlannerCubit');
      emit(MealPlannerLoading());

      // ✅ Query activity levels
      developer.log(
        '📥 Fetching activity levels from DB',
        name: 'MealPlannerCubit',
      );
      final response = await _supabase
          .from('activity_levels')
          .select()
          .order('number', ascending: true);

      developer.log('Response: $response', name: 'MealPlannerCubit');

      if (response == null || (response as List).isEmpty) {
        developer.log('❌ No activity levels found', name: 'MealPlannerCubit');
        emit(MealPlannerError('Không có dữ liệu mức độ hoạt động'));
        return;
      }

      developer.log(
        'Found ${(response as List).length} activity levels',
        name: 'MealPlannerCubit',
      );

      // ✅ Parse activity levels
      final levels = (response as List)
          .map((json) {
            try {
              final level = ActivityLevel.fromJson(
                json as Map<String, dynamic>,
              );
              developer.log(
                'Parsed level: ${level.title}',
                name: 'MealPlannerCubit',
              );
              return level;
            } catch (e) {
              developer.log(
                '❌ Failed to parse level: $e',
                name: 'MealPlannerCubit',
              );
              return null;
            }
          })
          .whereType<ActivityLevel>()
          .toList();

      if (levels.isEmpty) {
        developer.log(
          '❌ No valid levels after parsing',
          name: 'MealPlannerCubit',
        );
        emit(MealPlannerError('Lỗi load dữ liệu mức độ hoạt động'));
        return;
      }

      developer.log(
        '✅ Emitting ActivityLevelsLoaded with ${levels.length} levels',
        name: 'MealPlannerCubit',
      );
      emit(ActivityLevelsLoaded(levels));

      developer.log(
        '🎉 loadActivityLevels completed successfully',
        name: 'MealPlannerCubit',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in loadActivityLevels',
        name: 'MealPlannerCubit',
        error: e,
        stackTrace: stackTrace,
      );

      emit(MealPlannerError('Error loading activity levels: ${e.toString()}'));
      print('❌ Error loading activity levels: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// ✅ Check nếu user đã có activity preference
  Future<bool> checkActivityPreference() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // ✅ JOIN với activity_levels để lấy activity_factor
      final existing = await _supabase
          .from('user_activity_preferences')
          .select('for_activity_level, activity_levels!inner(activity_factor)')
          .eq('for_user', userId)
          .maybeSingle();

      if (existing != null) {
        // ✅ Lấy activity_factor từ JOIN
        final activityLevels = existing['activity_levels'] as Map?;
        final factor = activityLevels?['activity_factor'] as double? ?? 1.55;
        currentActivityFactor = factor;

        developer.log(
          '✅ Found preference with factor: $factor',
          name: 'MealPlannerCubit',
        );
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in checkActivityPreference',
        name: 'MealPlannerCubit',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// ✅ Refresh meals khi quay lại màn hình (qua ngày sẽ reset)
  Future<void> refreshMealsByDate(DateTime date) async {
    final now = DateTime.now();

    // ✅ Nếu ngày khác, clear cache và reload
    if (_lastLoadedDate?.year != now.year ||
        _lastLoadedDate?.month != now.month ||
        _lastLoadedDate?.day != now.day) {
      _lastLoadedDate = now;
      await loadMealsByDate(now);
    } else {
      // Cùng ngày thì reload bình thường
      await loadMealsByDate(date);
    }
  }

  /// Load meals by date
  Future<void> loadMealsByDate(DateTime date) async {
    try {
      _selectedDateTime = date;
      _lastLoadedDate = date;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      // ✅ Lấy target calories từ user_activity_preferences
      final pref = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      // ✅ Để null nếu chưa set, thay vì mặc định 2000
      int targetCalories = pref?['daily_calorie_target'] ?? 0;

      // ✅ Load meals của ngày hôm nay (reset qua ngày)
      final mealsByType = await loadMealsByDateAndType(date);
      final currentCalories = _calculateTotalCalories(mealsByType);

      // ✅ Emit loaded state với meals của ngày + goal không thay đổi
      emit(
        MealsLoaded(
          breakfast: mealsByType['breakfast'] ?? [],
          lunch: mealsByType['lunch'] ?? [],
          dinner: mealsByType['dinner'] ?? [],
          currentCalories: currentCalories,
          targetCalories: targetCalories, // ✅ Để 0 nếu chưa set
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

      // ✅ NGAY LẬP TỨC reload và emit
      final mealsByType = await loadMealsByDateAndType(date);
      final currentCalories = _calculateTotalCalories(mealsByType);

      // ✅ Lấy target calories
      final pref = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      int targetCalories = pref?['daily_calorie_target'] ?? 0;

      // ✅ Emit state MỚI ngay lập tức
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

      debugPrint(
        '✅ Meal added: ${meal['name']}, Total calories: $currentCalories',
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
          .eq('for_user', userId)
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

      // ✅ NGAY LẬP TỨC reload và emit
      await loadMealsByDate(_selectedDateTime);

      debugPrint('✅ Meal removed, reloaded calories');
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
