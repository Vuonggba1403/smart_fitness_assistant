import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';

/// Model đại diện cho kế hoạch tập luyện 7 ngày
class WorkoutPlan {
  final String id;
  final DateTime createdAt;
  final List<DailyPlan> dailyPlans;

  WorkoutPlan({
    required this.id,
    required this.createdAt,
    required this.dailyPlans,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dailyPlans: (json['daily_plans'] as List)
          .map((e) => DailyPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'daily_plans': dailyPlans.map((e) => e.toJson()).toList(),
    };
  }

  /// ✅ Thêm method để convert sang JSON đầy đủ (bao gồm nested objects)
  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'daily_plans': dailyPlans.map((plan) => plan.toFullJson()).toList(),
    };
  }

  /// ✅ Factory để parse từ JSON đầy đủ (bao gồm nested objects)
  factory WorkoutPlan.fromFullJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dailyPlans: (json['daily_plans'] as List)
          .map((e) => DailyPlan.fromFullJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model đại diện cho kế hoạch trong 1 ngày
class DailyPlan {
  final int dayNumber; // 1-7
  final String dayName; // "Thứ Hai", "Thứ Ba"...
  final List<WorkoutSession> workouts;
  final List<MealSession> meals;

  DailyPlan({
    required this.dayNumber,
    required this.dayName,
    required this.workouts,
    required this.meals,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      dayNumber: json['day_number'] as int,
      dayName: json['day_name'] as String,
      workouts: (json['workouts'] as List)
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      meals: (json['meals'] as List)
          .map((e) => MealSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      'day_name': dayName,
      'workouts': workouts.map((e) => e.toJson()).toList(),
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }

  /// ✅ Convert sang JSON đầy đủ
  Map<String, dynamic> toFullJson() {
    return {
      'day_number': dayNumber,
      'day_name': dayName,
      'workouts': workouts.map((w) => w.toFullJson()).toList(),
      'meals': meals.map((m) => m.toFullJson()).toList(),
    };
  }

  /// ✅ Parse từ JSON đầy đủ
  factory DailyPlan.fromFullJson(Map<String, dynamic> json) {
    return DailyPlan(
      dayNumber: json['day_number'] as int,
      dayName: json['day_name'] as String,
      workouts: (json['workouts'] as List)
          .map((e) => WorkoutSession.fromFullJson(e as Map<String, dynamic>))
          .toList(),
      meals: (json['meals'] as List)
          .map((e) => MealSession.fromFullJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model cho session tập luyện
class WorkoutSession {
  final ExerciseItem exercise;
  final int sets;
  final int reps;
  final int? durationMinutes;

  WorkoutSession({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.durationMinutes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      exercise: ExerciseItem.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets,
      'reps': reps,
      'duration_minutes': durationMinutes,
    };
  }

  /// ✅ Convert sang JSON đầy đủ (bao gồm exercise object)
  Map<String, dynamic> toFullJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets,
      'reps': reps,
      'duration_minutes': durationMinutes,
    };
  }

  /// ✅ Parse từ JSON đầy đủ
  factory WorkoutSession.fromFullJson(Map<String, dynamic> json) {
    return WorkoutSession(
      exercise: ExerciseItem.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }
}

/// Model cho session ăn uống
class MealSession {
  final String mealType; // "Bữa sáng", "Bữa trưa", "Bữa tối", "Bữa phụ"
  final Meal meal;
  final double servingSize; // Gấp bao nhiêu lần serving mặc định

  MealSession({
    required this.mealType,
    required this.meal,
    this.servingSize = 1.0,
  });

  factory MealSession.fromJson(Map<String, dynamic> json) {
    return MealSession(
      mealType: json['meal_type'] as String,
      meal: Meal.fromJson(json['meal'] as Map<String, dynamic>),
      servingSize: (json['serving_size'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'meal': meal.toJson(),
      'serving_size': servingSize,
    };
  }

  /// ✅ Tính tổng calories cho bữa ăn này
  int get totalCalories => (meal.calories * servingSize).round();

  /// ✅ Factory method để parse từ JSON đầy đủ
  factory MealSession.fromFullJson(Map<String, dynamic> json) {
    return MealSession(
      mealType: json['meal_type'] as String,
      meal: Meal.fromJson(json['meal'] as Map<String, dynamic>),
      servingSize: (json['serving_size'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// ✅ Convert sang JSON đầy đủ
  Map<String, dynamic> toFullJson() {
    return {
      'meal_type': mealType,
      'meal': meal.toJson(),
      'serving_size': servingSize,
    };
  }
}
