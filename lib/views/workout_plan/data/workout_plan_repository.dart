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

  /// Fetch exercises từ Supabase
  Future<List<ExerciseItem>> fetchExercises() async {
    try {
      final response = await _supabase.from('exercise_items').select('''
            *,
            devices:exercise_devices(
              device:devices(*)
            )
          ''');

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

  /// Fetch meals từ Supabase
  Future<List<Meal>> fetchMeals() async {
    try {
      final response = await _supabase
          .from('meals')
          .select()
          .eq('is_verified', true);

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
  }) async {
    try {
      final userContext = _buildUserContext(
        user,
        activityLevel,
        fitnessProfile,
      );
      final exercisesList = _buildExercisesListWithIndex(exercises);
      final mealsList = _buildMealsListWithIndex(meals);
      final prompt = _buildPrompt(userContext, exercisesList, mealsList);

      log('📤 Sending prompt to Gemini AI...');

      final response = await _gemini.text(prompt);

      if (response?.output == null) {
        throw Exception('No response from AI');
      }

      log('✅ Received response from AI');

      final plan = _parseAIResponseWithIndex(
        response!.output!,
        exercises,
        meals,
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
  ) {
    return '''
User Profile:
- Tuổi: ${user.age}
- Chiều cao: ${user.height} cm
- Cân nặng hiện tại: ${user.weight} kg
- Cân nặng mục tiêu: ${user.weight_goal} kg
- Mục tiêu: ${user.your_goals}
- Mức độ hoạt động: ${level.title} (${level.description})
- Activity Factor: ${level.activityFactor}

${fitnessProfile.toPromptString()}
''';
  }

  /// Build exercises list với INDEX
  String _buildExercisesListWithIndex(List<ExerciseItem> exercises) {
    final buffer = StringBuffer('Available Exercises (USE INDEX):\n');
    for (var i = 0; i < exercises.take(30).length; i++) {
      final ex = exercises[i];
      buffer.writeln('[INDEX: $i] ${ex.title} (${ex.muscleGroupsString})');
    }
    buffer.writeln('\n✅ CRITICAL: Use INDEX number (0-29) as exercise_id');
    return buffer.toString();
  }

  /// Build meals list với INDEX
  String _buildMealsListWithIndex(List<Meal> meals) {
    final buffer = StringBuffer('Available Meals (USE INDEX):\n');
    for (var i = 0; i < meals.take(30).length; i++) {
      final meal = meals[i];
      buffer.writeln(
        '[INDEX: $i] ${meal.name} (${meal.calories} cal, P:${meal.proteinG}g C:${meal.carbsG}g F:${meal.fatG}g)',
      );
    }
    buffer.writeln('\n✅ CRITICAL: Use INDEX number (0-29) as meal_id');
    return buffer.toString();
  }

  /// Build prompt cho AI
  String _buildPrompt(String userContext, String exercises, String meals) {
    return '''
You are a professional fitness coach. Create a 7-day workout and meal plan.

$userContext

$exercises

$meals

⚠️⚠️⚠️ CRITICAL REQUIREMENTS - READ CAREFULLY ⚠️⚠️⚠️

1. ✅ USE INDEX NUMBERS (0-29) for exercise_id and meal_id
   Example CORRECT: "exercise_id": 5
   Example WRONG: "exercise_id": "abc123"

2. ✅ Return PURE JSON ONLY - NO markdown, NO explanations

3. ✅ Adjust difficulty based on fitness level

4. ✅ Filter exercises based on equipment access

5. ✅ Avoid exercises that may aggravate existing injuries

6. ✅ Respect dietary preferences and allergies

7. ✅ Create balanced workout targeting different muscle groups

8. ✅ Calculate meals to match user's calorie needs

9. ✅ Include 3-4 exercises per day

10. ✅ Include 3-4 meals per day

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
      }
    ],
    "meals": [
      {
        "meal_type": "Bữa sáng",
        "meal_id": 5,
        "serving_size": 1.0
      }
    ]
  }
]

REMEMBER: 
- Use INDEX numbers (0-29) for exercise_id and meal_id
- Return ONLY the JSON array
- Day names: "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"
- Meal types: "Bữa sáng", "Bữa trưa", "Bữa tối", "Bữa phụ"
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

      if (dailyPlansJson.length != 7) {
        log('⚠️ Warning: Expected 7 days, got ${dailyPlansJson.length}');
      }

      final dailyPlans = <DailyPlan>[];

      for (var dayData in dailyPlansJson) {
        // Parse workouts với INDEX
        final workouts = <WorkoutSession>[];
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

        // Parse meals với INDEX
        final mealSessions = <MealSession>[];
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
