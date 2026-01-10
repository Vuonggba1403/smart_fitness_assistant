import 'dart:developer';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class WorkoutPlanRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Gemini _gemini = Gemini.instance;

  /// Fetch activity levels từ Supabase
  Future<List<ActivityLevel>> fetchActivityLevels() async {
    try {
      final response = await _supabase
          .from('activity_levels')
          .select()
          .order('number', ascending: true);

      return (response as List)
          .map((json) => ActivityLevel.fromJson(json))
          .toList();
    } catch (e) {
      log('❌ Error fetching activity levels: $e');
      rethrow;
    }
  }

  /// Fetch exercises từ Supabase (with optional limit for performance)
  Future<List<ExerciseItem>> fetchExercises({int? limit}) async {
    try {
      dynamic query = _supabase.from('exercise_items').select('''
            *,
            devices:exercise_devices(
              device:devices(*)
            )
          ''');

      // Add limit if specified (for better performance)
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((json) {
        if (json['devices'] != null) {
          json['devices'] = (json['devices'] as List)
              .map((ed) => ed['device'])
              .toList();
        }
        return ExerciseItem.fromJson(json);
      }).toList();
    } catch (e) {
      log('❌ Error fetching exercises: $e');
      rethrow;
    }
  }

  /// Fetch meals từ Supabase (with optional limit for performance)
  Future<List<Meal>> fetchMeals({int? limit}) async {
    try {
      dynamic query = _supabase
          .from('meals')
          .select('*, name_en, description_en')
          .eq('is_verified', true);

      // Add limit if specified (for better performance)
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((json) => Meal.fromJson(json)).toList();
    } catch (e) {
      log('❌ Error fetching meals: $e');
      rethrow;
    }
  }

  /// Generate workout plan bằng AI
  Future<WorkoutPlan> generatePlan({
    required UserDataModel user,
    required ActivityLevel activityLevel,
    required UserFitnessProfile fitnessProfile,
    required List<ExerciseItem> exercises,
    required List<Meal> meals,
    int? dailyCalorieTarget,
  }) async {
    try {
      // ✅ Filter exercises theo user profile trước khi gửi AI
      final filteredExercises = _filterExercises(exercises, fitnessProfile);
      log(
        '📊 Filtered exercises: ${exercises.length} → ${filteredExercises.length}',
      );

      // ✅ Filter meals theo dietary preferences trước khi gửi AI
      final filteredMeals = _filterMeals(meals, fitnessProfile);
      log('📊 Filtered meals: ${meals.length} → ${filteredMeals.length}');

      // ✅ Validation: Đảm bảo có đủ exercises và meals
      if (filteredExercises.length < 10) {
        log(
          '⚠️ Warning: Only ${filteredExercises.length} exercises available after filtering. Using unfiltered list.',
        );
        // Fallback: Sử dụng danh sách gốc nếu filter quá nhiều
        return generatePlan(
          user: user,
          activityLevel: activityLevel,
          fitnessProfile: UserFitnessProfile(
            fitnessLevel: fitnessProfile.fitnessLevel,
            equipment: fitnessProfile.equipment,
            // Bỏ qua injuries để có nhiều exercises hơn
            injuries: [],
          ),
          exercises: exercises,
          meals: meals,
          dailyCalorieTarget: dailyCalorieTarget,
        );
      }

      if (filteredMeals.length < 10) {
        log(
          '⚠️ Warning: Only ${filteredMeals.length} meals available after filtering. Using unfiltered list.',
        );
        // Fallback: Sử dụng danh sách gốc
        return generatePlan(
          user: user,
          activityLevel: activityLevel,
          fitnessProfile: UserFitnessProfile(
            fitnessLevel: fitnessProfile.fitnessLevel,
            equipment: fitnessProfile.equipment,
            // Bỏ qua dietary preferences để có nhiều meals hơn
          ),
          exercises: exercises,
          meals: meals,
          dailyCalorieTarget: dailyCalorieTarget,
        );
      }

      final userContext = _buildUserContext(
        user,
        activityLevel,
        fitnessProfile,
        dailyCalorieTarget,
      );
      final exercisesList = _buildExercisesListWithIndex(filteredExercises);
      final mealsList = _buildMealsListWithIndex(filteredMeals);
      final prompt = _buildPrompt(
        userContext,
        exercisesList,
        mealsList,
        dailyCalorieTarget,
      );

      log('📤 Sending prompt to Gemini AI...');

      final response = await _gemini.text(prompt);

      if (response?.output == null) {
        throw Exception('No response from AI');
      }

      log('✅ Received response from AI');

      final plan = _parseAIResponseWithIndex(
        response!.output!,
        filteredExercises,
        filteredMeals,
      );

      return plan;
    } catch (e) {
      log('❌ Error generating plan: $e');
      rethrow;
    }
  }

  /// Build user context
  String _buildUserContext(
    UserDataModel user,
    ActivityLevel level,
    UserFitnessProfile fitnessProfile,
    int? dailyCalorieTarget,
  ) {
    final calorieInfo = dailyCalorieTarget != null
        ? '- Mục tiêu calo hàng ngày: $dailyCalorieTarget kcal (từ Meal Planner)'
        : '- Mục tiêu calo hàng ngày: Tự động tính toán dựa trên mục tiêu';

    return '''
User Profile:
- Tuổi: ${user.age}
- Chiều cao: ${user.height} cm
- Cân nặng hiện tại: ${user.weight} kg
- Cân nặng mục tiêu: ${user.weight_goal} kg
- Mục tiêu: ${user.your_goals}
- Mức độ hoạt động: ${level.title} (${level.description})
- Activity Factor: ${level.activityFactor}
$calorieInfo

${fitnessProfile.toPromptString()}
''';
  }

  /// ✅ Filter exercises dựa trên UserFitnessProfile
  List<ExerciseItem> _filterExercises(
    List<ExerciseItem> exercises,
    UserFitnessProfile profile,
  ) {
    return exercises.where((exercise) {
      // 1. Filter theo equipment
      if (profile.equipment == 'home') {
        // Chỉ lấy exercises không cần thiết bị phức tạp
        final hasGymEquipment = exercise.devices.any((device) {
          final deviceName = device.name.toLowerCase();
          return deviceName.contains('barbell') ||
              deviceName.contains('tạ đòn') ||
              deviceName.contains('machine') ||
              deviceName.contains('máy') ||
              deviceName.contains('cable') ||
              deviceName.contains('dây cáp');
        });
        if (hasGymEquipment) return false;
      }

      // 2. Filter theo injuries
      for (var injury in profile.injuries) {
        final injuryLower = injury.toLowerCase();

        // Back injuries - tránh exercises tác động lên lưng
        if (injuryLower.contains('back') || injuryLower.contains('lưng')) {
          final muscleGroups = exercise.muscleGroups.join(' ').toLowerCase();
          if (muscleGroups.contains('lưng') ||
              muscleGroups.contains('back') ||
              exercise.title.toLowerCase().contains('deadlift') ||
              exercise.title.toLowerCase().contains('gánh tạ')) {
            return false;
          }
        }

        // Knee injuries - tránh exercises tác động lên đầu gối
        if (injuryLower.contains('knee') || injuryLower.contains('gối')) {
          final titleLower = exercise.title.toLowerCase();
          if (titleLower.contains('squat') ||
              titleLower.contains('lunge') ||
              titleLower.contains('gánh') ||
              titleLower.contains('chạy') ||
              titleLower.contains('run')) {
            return false;
          }
        }

        // Shoulder injuries - tránh exercises tác động lên vai
        if (injuryLower.contains('shoulder') || injuryLower.contains('vai')) {
          final muscleGroups = exercise.muscleGroups.join(' ').toLowerCase();
          if (muscleGroups.contains('vai') ||
              muscleGroups.contains('shoulder') ||
              exercise.title.toLowerCase().contains('press') ||
              exercise.title.toLowerCase().contains('đẩy')) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  /// ✅ Filter meals dựa trên dietary preferences và allergies
  List<Meal> _filterMeals(List<Meal> meals, UserFitnessProfile profile) {
    return meals.where((meal) {
      final mealName = meal.name.toLowerCase();
      final mealDesc = (meal.description ?? '').toLowerCase();

      // 1. Filter theo dietary preferences
      for (var pref in profile.dietaryPreferences) {
        final prefLower = pref.toLowerCase();

        if (prefLower.contains('vegetarian') || prefLower.contains('chay')) {
          // Loại bỏ món có thịt, cá
          if (mealName.contains('thịt') ||
              mealName.contains('meat') ||
              mealName.contains('gà') ||
              mealName.contains('chicken') ||
              mealName.contains('cá') ||
              mealName.contains('fish') ||
              mealName.contains('heo') ||
              mealName.contains('pork') ||
              mealName.contains('bò') ||
              mealName.contains('beef') ||
              mealDesc.contains('thịt') ||
              mealDesc.contains('meat')) {
            return false;
          }
        }

        if (prefLower.contains('vegan')) {
          // Loại bỏ tất cả sản phẩm động vật
          if (mealName.contains('thịt') ||
              mealName.contains('meat') ||
              mealName.contains('sữa') ||
              mealName.contains('milk') ||
              mealName.contains('trứng') ||
              mealName.contains('egg') ||
              mealName.contains('phô mai') ||
              mealName.contains('cheese') ||
              mealDesc.contains('thịt') ||
              mealDesc.contains('sữa') ||
              mealDesc.contains('trứng')) {
            return false;
          }
        }

        if (prefLower.contains('halal')) {
          // Loại bỏ thịt heo
          if (mealName.contains('heo') ||
              mealName.contains('pork') ||
              mealName.contains('lợn') ||
              mealDesc.contains('heo') ||
              mealDesc.contains('pork')) {
            return false;
          }
        }
      }

      // 2. Filter theo food allergies
      for (var allergy in profile.foodAllergies) {
        final allergyLower = allergy.toLowerCase();

        if (allergyLower.contains('peanut') || allergyLower.contains('đậu')) {
          if (mealName.contains('đậu') ||
              mealName.contains('peanut') ||
              mealDesc.contains('đậu phộng')) {
            return false;
          }
        }

        if (allergyLower.contains('shellfish') ||
            allergyLower.contains('hải sản')) {
          if (mealName.contains('tôm') ||
              mealName.contains('cua') ||
              mealName.contains('shrimp') ||
              mealName.contains('crab') ||
              mealDesc.contains('hải sản')) {
            return false;
          }
        }

        if (allergyLower.contains('dairy') || allergyLower.contains('sữa')) {
          if (mealName.contains('sữa') ||
              mealName.contains('milk') ||
              mealName.contains('phô mai') ||
              mealName.contains('cheese') ||
              mealDesc.contains('sữa')) {
            return false;
          }
        }

        if (allergyLower.contains('gluten')) {
          if (mealName.contains('bánh mì') ||
              mealName.contains('bread') ||
              mealName.contains('mì') ||
              mealName.contains('noodle') ||
              mealDesc.contains('gluten')) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  /// Build exercises list với INDEX
  String _buildExercisesListWithIndex(List<ExerciseItem> exercises) {
    final buffer = StringBuffer('Available Exercises (USE INDEX):\n');

    // ✅ Lấy tối đa 30 exercises từ danh sách đã được filter
    final exercisesToUse = exercises.take(30).toList();

    for (var i = 0; i < exercisesToUse.length; i++) {
      final ex = exercisesToUse[i];
      buffer.writeln('[INDEX: $i] ${ex.title} (${ex.muscleGroupsString})');
    }

    buffer.writeln(
      '\n✅ CRITICAL: Use INDEX number (0-${exercisesToUse.length - 1}) as exercise_id',
    );
    buffer.writeln('⚠️ Total available exercises: ${exercisesToUse.length}');

    return buffer.toString();
  }

  /// Build meals list với INDEX
  String _buildMealsListWithIndex(List<Meal> meals) {
    final buffer = StringBuffer('Available Meals (USE INDEX):\n');

    // ✅ Lấy tối đa 30 meals từ danh sách đã được filter
    final mealsToUse = meals.take(30).toList();

    for (var i = 0; i < mealsToUse.length; i++) {
      final meal = mealsToUse[i];
      buffer.writeln(
        '[INDEX: $i] ${meal.name} (${meal.calories} cal, P:${meal.proteinG}g C:${meal.carbsG}g F:${meal.fatG}g)',
      );
    }

    buffer.writeln(
      '\n✅ CRITICAL: Use INDEX number (0-${mealsToUse.length - 1}) as meal_id',
    );
    buffer.writeln('⚠️ Total available meals: ${mealsToUse.length}');

    return buffer.toString();
  }

  /// Build prompt cho AI
  String _buildPrompt(
    String userContext,
    String exercises,
    String meals,
    int? dailyCalorieTarget,
  ) {
    return '''
You are a professional fitness coach. Create a 30-day workout and meal plan.

$userContext

$exercises

$meals

⚠️⚠️⚠️ CRITICAL REQUIREMENTS - READ CAREFULLY ⚠️⚠️⚠️

1. ✅ USE INDEX NUMBERS (0-${exercises.length - 1}) for exercise_id
   USE INDEX NUMBERS (0-${meals.length - 1}) for meal_id
   Example CORRECT: "exercise_id": 5, "meal_id": 12
   Example WRONG: "exercise_id": "abc123"

2. ✅ Return PURE JSON ONLY - NO markdown, NO explanations

3. ✅ Adjust difficulty based on fitness level

4. ✅ Filter exercises based on equipment access

5. ✅ Avoid exercises that may aggravate existing injuries

6. ✅ Respect dietary preferences and allergies

7. ✅ Create balanced workout targeting different muscle groups

8. ✅ Calculate meals to match user's DAILY CALORIE TARGET from profile
   ${dailyCalorieTarget != null ? '⚠️ USER TARGET: $dailyCalorieTarget kcal/day - USE THIS EXACT VALUE!' : 'Calculate based on user goals and activity level'}

9. ⚠️ MANDATORY: Include exactly 4-5 exercises per day (NO LESS than 4)

10. ⚠️⚠️ ABSOLUTELY MANDATORY - EVERY DAY MUST HAVE MEALS ⚠️⚠️
    Include exactly 3-4 meals per day:
    - MUST have: "Bữa sáng" (Breakfast)
    - MUST have: "Bữa trưa" (Lunch)  
    - MUST have: "Bữa tối" (Dinner)
    - OPTIONAL: "Bữa phụ" (Snack) if user needs more calories
    
    ❌ CRITICAL: Do NOT skip meals for any day!
    ❌ Every single day (1-30) MUST have at least 3 meals!
    ❌ If you skip meals, the plan will be REJECTED!

11. ✅ Distribute calories across meals to reach ${dailyCalorieTarget ?? 'target'}:
    - Breakfast: 25-30% of daily calories
    - Lunch: 35-40% of daily calories
    - Dinner: 25-30% of daily calories
    - Snack: 10-15% of daily calories (if included)
    ${dailyCalorieTarget != null ? '⚠️ Total daily calories MUST be close to $dailyCalorieTarget kcal!' : ''}

EXACT JSON FORMAT (NO EXCEPTIONS):
[
  {
    "day_number": 1,
    "day_name": "Thứ Hai",
    "workouts": [
      {
        "exercise_id": 0,
        "sets": 3,
        "reps": 12,
        "duration_minutes": 30
      },
      {
        "exercise_id": 1,
        "sets": 3,
        "reps": 15,
        "duration_minutes": 25
      },
      {
        "exercise_id": 2,
        "sets": 4,
        "reps": 10,
        "duration_minutes": 20
      },
      {
        "exercise_id": 3,
        "sets": 3,
        "reps": 12,
        "duration_minutes": 15
      }
    ],
    "meals": [
      {
        "meal_type": "Bữa sáng",
        "meal_id": 5,
        "serving_size": 1.0
      },
      {
        "meal_type": "Bữa trưa",
        "meal_id": 12,
        "serving_size": 1.0
      },
      {
        "meal_type": "Bữa tối",
        "meal_id": 18,
        "serving_size": 1.0
      },
      {
        "meal_type": "Bữa phụ",
        "meal_id": 25,
        "serving_size": 1.0
      }
    ]
  }
]

REMEMBER: 
- Use INDEX numbers (0-${meals.length - 1}) for meal_id, (0-${exercises.length - 1}) for exercise_id
- Return ONLY the JSON array
- ❗ CRITICAL: Each day MUST have 4-5 exercises AND 3-4 meals (DO NOT skip meals!)
- Day names cycle: "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật" (repeat for 30 days)
- Every day from 1 to 30 MUST include a "meals" array with at least 3 meal objects

Return ONLY the JSON array, NO markdown, NO explanations.
- Meal types: "Bữa sáng", "Bữa trưa", "Bữa tối", "Bữa phụ"
- Create progressive difficulty: easier exercises at start, more challenging towards day 30
- Vary muscle groups to allow recovery
''';
  }

  /// Parse AI response với INDEX
  WorkoutPlan _parseAIResponseWithIndex(
    String aiOutput,
    List<ExerciseItem> exercises,
    List<Meal> meals,
  ) {
    try {
      // Clean JSON
      String cleanJson = aiOutput.trim();

      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      // Remove text before first [ or {
      final firstBracket = cleanJson.indexOf('[');
      final firstBrace = cleanJson.indexOf('{');

      if (firstBracket != -1 &&
          (firstBrace == -1 || firstBracket < firstBrace)) {
        cleanJson = cleanJson.substring(firstBracket);
      } else if (firstBrace != -1) {
        cleanJson = cleanJson.substring(firstBrace);
      }

      // Remove text after last ] or }
      final lastBracket = cleanJson.lastIndexOf(']');
      final lastBrace = cleanJson.lastIndexOf('}');

      if (lastBracket != -1 && lastBracket > lastBrace) {
        cleanJson = cleanJson.substring(0, lastBracket + 1);
      } else if (lastBrace != -1) {
        cleanJson = cleanJson.substring(0, lastBrace + 1);
      }

      final jsonData = json.decode(cleanJson);

      List<dynamic> dailyPlansJson;

      if (jsonData is Map && jsonData.containsKey('daily_plans')) {
        dailyPlansJson = jsonData['daily_plans'] as List;
      } else if (jsonData is List) {
        dailyPlansJson = jsonData;
      } else {
        throw Exception('Invalid JSON format');
      }

      if (dailyPlansJson.length != 30) {
        log('⚠️ Warning: Expected 30 days, got ${dailyPlansJson.length}');
      }

      final dailyPlans = <DailyPlan>[];

      for (var dayData in dailyPlansJson) {
        // Parse workouts với INDEX
        final workouts = <WorkoutSession>[];
        if (dayData['workouts'] != null && dayData['workouts'] is List) {
          for (var workoutData in dayData['workouts']) {
            final exerciseIndex = workoutData['exercise_id'];

            int index = exerciseIndex is int
                ? exerciseIndex
                : int.tryParse(exerciseIndex.toString()) ?? 0;

            if (index < 0 || index >= exercises.length) {
              log('⚠️ Invalid exercise index: $index, using 0');
              index = 0;
            }

            final exercise = exercises[index];

            workouts.add(
              WorkoutSession(
                exercise: exercise,
                sets: workoutData['sets'] as int,
                reps: workoutData['reps'] as int,
                durationMinutes: workoutData['duration_minutes'] as int?,
              ),
            );
          }
        }

        // Validate workout count
        if (workouts.length < 4) {
          log(
            '⚠️ Day ${dayData['day_number']} has only ${workouts.length} exercises, expected 4-5',
          );
        }

        // Parse meals với INDEX
        final mealSessions = <MealSession>[];
        if (dayData['meals'] != null && dayData['meals'] is List) {
          for (var mealData in dayData['meals']) {
            final mealIndex = mealData['meal_id'];

            int index = mealIndex is int
                ? mealIndex
                : int.tryParse(mealIndex.toString()) ?? 0;

            if (index < 0 || index >= meals.length) {
              log('⚠️ Invalid meal index: $index, using 0');
              index = 0;
            }

            final meal = meals[index];

            mealSessions.add(
              MealSession(
                mealType: mealData['meal_type'] as String,
                meal: meal,
                servingSize:
                    (mealData['serving_size'] as num?)?.toDouble() ?? 1.0,
              ),
            );
          }
        } else {
          log('⚠️ No meals found for day ${dayData['day_number']}');
        }

        // Validate meal count
        if (mealSessions.length < 3) {
          log(
            '⚠️ Day ${dayData['day_number']} has only ${mealSessions.length} meals, expected 3-4',
          );
        }

        // Validate required meal types
        final mealTypes = mealSessions.map((m) => m.mealType).toSet();
        final requiredTypes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối'];
        for (var required in requiredTypes) {
          if (!mealTypes.contains(required)) {
            log(
              '⚠️ Day ${dayData['day_number']} missing required meal type: $required',
            );
          }
        }

        dailyPlans.add(
          DailyPlan(
            dayNumber: dayData['day_number'] as int,
            dayName: dayData['day_name'] as String,
            workouts: workouts,
            meals: mealSessions,
          ),
        );
      }

      log('✅ Successfully parsed plan with ${dailyPlans.length} days');

      // Debug meals count
      for (var day in dailyPlans) {
        log('📅 Parsed Day ${day.dayNumber}: ${day.meals.length} meals');
      }

      return WorkoutPlan(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        dailyPlans: dailyPlans,
      );
    } catch (e, stackTrace) {
      log('❌ Error parsing AI response: $e');
      log('Stack trace: $stackTrace');
      log(
        'Raw response (first 500 chars): ${aiOutput.substring(0, aiOutput.length > 500 ? 500 : aiOutput.length)}',
      );
      rethrow;
    }
  }
}
