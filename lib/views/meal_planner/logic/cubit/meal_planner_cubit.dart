import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
      debugPrint(
        '🔵 Loading meals for date: ${DateFormat('yyyy-MM-dd').format(date)}',
      );
      _selectedDateTime = date;
      _lastLoadedDate = date;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ User not authenticated in loadMealsByDate');
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
      debugPrint('🎯 Target calories: $targetCalories');

      // Load meals của ngày
      final mealsByType = await loadMealsByDateAndType(date);
      debugPrint(
        '📊 Loaded meals by type: ${mealsByType.map((k, v) => MapEntry(k, v.length))}',
      );

      final currentCalories = _calculateTotalCalories(mealsByType);
      debugPrint('🔥 Current calories: $currentCalories');

      emit(
        MealsLoaded(
          breakfast: mealsByType['breakfast'] ?? [],
          lunch: mealsByType['lunch'] ?? [],
          dinner: mealsByType['dinner'] ?? [],
          snack: mealsByType['snack'] ?? [],
          currentCalories: currentCalories,
          targetCalories: targetCalories,
          selectedDateTime: date,
        ),
      );

      debugPrint('✅ MealsLoaded state emitted successfully');
    } catch (e) {
      debugPrint('❌ Error in loadMealsByDate: $e');
      emit(MealPlannerError('Error loading meals: ${e.toString()}'));
    }
  }

  /// ➕ Thêm meal vào loại bữa ăn
  Future<void> addMealToType(String mealType, Map meal, DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ User not authenticated');
        emit(MealPlannerError('User not authenticated'));
        return;
      }

      debugPrint('🔵 Adding meal: ${meal['name']} to $mealType');
      debugPrint('📦 Meal data: $meal');

      // ✅ BƯỚC 1: Đảm bảo meal tồn tại trong bảng meals
      final mealId = await _ensureMealExists(meal);

      debugPrint('✅ Meal ID: $mealId');

      // ✅ BƯỚC 2: Lưu vào user_meals (với tên theo locale)
      final locale = Get.locale?.languageCode;
      final mealName =
          (locale == 'en' &&
              meal['name_en'] != null &&
              (meal['name_en'] as String).isNotEmpty)
          ? meal['name_en']
          : meal['name'];

      final userMealData = {
        'for_user': userId,
        'for_meal': mealId,
        'meal_name': mealName,
        'meal_type': mealType,
        'calories': meal['calories'] ?? 0,
        'protein_g': meal['protein'] ?? 0.0,
        'carbs_g': meal['carbs'] ?? 0.0,
        'fat_g': meal['fat'] ?? 0.0,
        'serving_size_g': meal['serving_size'] ?? 100,
        'meal_date': DateFormat('yyyy-MM-dd').format(date),
        'meal_time': DateFormat('HH:mm').format(date),
      };

      debugPrint('📥 Inserting user_meal: $userMealData');
      await _supabase.from('user_meals').insert(userMealData);

      // ✅ BƯỚC 3: Reload và emit state mới
      debugPrint('🔄 Reloading meals for date: $date');
      await loadMealsByDate(date);

      debugPrint('✅ Meal added successfully: ${meal['name']} to $mealType');
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding meal: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MealPlannerError('Error adding meal: ${e.toString()}'));
    }
  }

  /// 🔧 Đảm bảo meal tồn tại trong bảng meals (upsert)
  Future<String> _ensureMealExists(Map meal) async {
    try {
      final originalId = meal['id']?.toString() ?? '';
      final barcode = meal['barcode']?.toString();

      if (originalId.isEmpty) {
        throw Exception('Meal ID is empty');
      }

      // 🔍 Nếu là barcode meal (ID không phải UUID), tìm theo barcode
      if (barcode != null && barcode.isNotEmpty) {
        debugPrint('🔍 Checking barcode meal: $barcode');

        // Tìm meal theo barcode
        final existing = await _supabase
            .from('meals')
            .select('id')
            .eq('barcode', barcode)
            .maybeSingle();

        if (existing != null) {
          final existingId = existing['id'] as String;
          debugPrint('✅ Barcode meal exists with UUID: $existingId');
          return existingId;
        }

        // Tạo UUID mới cho barcode meal
        const uuid = Uuid();
        final newUuid = uuid.v4();
        debugPrint('➕ Creating new UUID for barcode meal: $newUuid');

        await _supabase.from('meals').insert({
          'id': newUuid,
          'name': meal['name'] ?? 'Unknown',
          'calories': meal['base_calories'] ?? meal['calories'] ?? 0,
          'serving_size_g': 100, // Always store as per 100g
          'protein_g': meal['base_protein'] ?? meal['protein'] ?? 0.0,
          'carbs_g': meal['base_carbs'] ?? meal['carbs'] ?? 0.0,
          'fat_g': meal['base_fat'] ?? meal['fat'] ?? 0.0,
          'fiber_g': meal['fiber'] ?? 0.0,
          'cholesterol_mg': meal['cholesterol'] ?? 0.0,
          'is_verified': meal['is_verified'] ?? false,
          'image_url': meal['image_url'],
          'barcode': barcode,
        });

        debugPrint('✅ Barcode meal inserted with UUID: $newUuid');
        return newUuid;
      }

      // 🔍 Meal thường (có UUID từ database)
      final existing = await _supabase
          .from('meals')
          .select('id')
          .eq('id', originalId)
          .maybeSingle();

      if (existing != null) {
        debugPrint('✅ Meal already exists in database: $originalId');
        return originalId;
      }

      // Insert meal mới với UUID hiện có
      debugPrint('➕ Inserting new meal into database: $originalId');
      await _supabase.from('meals').insert({
        'id': originalId,
        'name': meal['name'] ?? 'Unknown',
        'calories': meal['base_calories'] ?? meal['calories'] ?? 0,
        'serving_size_g': 100,
        'protein_g': meal['base_protein'] ?? meal['protein'] ?? 0.0,
        'carbs_g': meal['base_carbs'] ?? meal['carbs'] ?? 0.0,
        'fat_g': meal['base_fat'] ?? meal['fat'] ?? 0.0,
        'fiber_g': meal['fiber'] ?? 0.0,
        'cholesterol_mg': meal['cholesterol'] ?? 0.0,
        'is_verified': meal['is_verified'] ?? false,
        'image_url': meal['image_url'],
        'barcode': meal['barcode'],
      });

      debugPrint('✅ Meal inserted successfully: $originalId');
      return originalId;
    } catch (e) {
      debugPrint('❌ Error ensuring meal exists: $e');
      rethrow;
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
  Future<void> searchMeals(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchMealInitial());
      return;
    }

    emit(SearchMealLoading());

    try {
      final response = await _supabase
          .from('meals')
          .select('*, name_en, description_en')
          .ilike('name', '%$query%')
          .eq('is_verified', true)
          .order('name')
          .limit(30);

      if ((response as List).isEmpty) {
        emit(SearchMealEmpty());
        return;
      }

      final meals = (response as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(SearchMealLoaded(meals));
    } catch (e) {
      debugPrint('❌ Error searching meals: $e');
      emit(SearchMealError(e.toString()));
    }
  }

  /// 📥 Load recent meals của user
  Future<void> loadRecentMeals() async {
    emit(SearchMealLoading());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(SearchMealError('User not authenticated'));
        return;
      }

      // Lấy 10 meals gần nhất từ user_meals
      final response = await _supabase
          .from('user_meals')
          .select('for_meal')
          .eq('for_user', userId)
          .order('created_at', ascending: false)
          .limit(10);

      if ((response as List).isEmpty) {
        emit(SearchMealEmpty());
        return;
      }

      // Lấy unique meal IDs
      final mealIds = (response as List)
          .map((e) => e['for_meal'] as String)
          .toSet()
          .toList();

      // Fetch chi tiết meals
      final mealsResponse = await _supabase
          .from('meals')
          .select('*, name_en, description_en')
          .inFilter('id', mealIds);

      if ((mealsResponse as List).isEmpty) {
        emit(SearchMealEmpty());
        return;
      }

      final meals = (mealsResponse as List)
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(SearchMealLoaded(meals));
    } catch (e) {
      debugPrint('❌ Error loading recent meals: $e');
      emit(SearchMealError(e.toString()));
    }
  }

  /// 🔄 Reset search về initial state
  void resetSearch() {
    emit(SearchMealInitial());
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

      developer.log(
        '📥 Loading meals for date: $dateStr, userId: $userId',
        name: 'MealPlannerCubit',
      );

      final response = await _supabase
          .from('user_meals')
          .select('*, meals!user_meals_for_meal_fkey(name, name_en)')
          .eq('for_user', userId)
          .eq('meal_date', dateStr)
          .order('meal_time', ascending: true);

      developer.log(
        '📊 Query result: ${(response as List).length} meals found',
        name: 'MealPlannerCubit',
      );

      if ((response as List).isEmpty) {
        return {'breakfast': [], 'lunch': [], 'dinner': [], 'snack': []};
      }

      // Nhóm meals theo meal_type
      final meals = response as List;
      final groupedMeals = <String, List<Map>>{
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };

      for (var meal in meals) {
        final mealType = meal['meal_type'] as String;
        if (groupedMeals.containsKey(mealType)) {
          groupedMeals[mealType]!.add(meal as Map);
        }
      }

      // ✅ Sắp xếp meals trong mỗi loại theo meal_time
      groupedMeals.forEach((key, mealsList) {
        mealsList.sort((a, b) {
          final timeA = a['meal_time'] as String? ?? '00:00';
          final timeB = b['meal_time'] as String? ?? '00:00';
          return timeA.compareTo(timeB);
        });
      });

      return groupedMeals;
    } catch (e) {
      debugPrint('Error loading meals by type: $e');
      return {'breakfast': [], 'lunch': [], 'dinner': [], 'snack': []};
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
