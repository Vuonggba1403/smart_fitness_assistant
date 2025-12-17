part of 'meal_planner_cubit.dart';

sealed class MealPlannerState {}

final class MealPlannerInitial extends MealPlannerState {}

final class MealPlannerLoading extends MealPlannerState {}

final class DateTimeUpdated extends MealPlannerState {
  final DateTime selectedDateTime;
  DateTimeUpdated(this.selectedDateTime);
}

final class ActivityPreferenceSaved extends MealPlannerState {
  final String activityId;
  final int dailyCalories;

  ActivityPreferenceSaved(this.activityId, this.dailyCalories);
}

final class ActivityLevelsLoaded extends MealPlannerState {
  final List<ActivityLevel> activityLevels;

  ActivityLevelsLoaded(this.activityLevels);
}

final class MealsLoaded extends MealPlannerState {
  final List<Map> breakfast;
  final List<Map> lunch;
  final List<Map> dinner;
  final int currentCalories;
  final int targetCalories;
  final DateTime selectedDateTime;
  MealsLoaded({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.currentCalories,
    required this.targetCalories,
    required this.selectedDateTime,
  });
}

final class MealAdded extends MealPlannerState {
  final String mealType;
  final String mealName;
  final int calories;
  final DateTime dateTime;

  MealAdded({
    required this.mealType,
    required this.mealName,
    required this.calories,
    required this.dateTime,
  });
}

final class MealRemoved extends MealPlannerState {
  final String mealType;
  MealRemoved(this.mealType);
}

final class MealPlannerError extends MealPlannerState {
  final String message;
  MealPlannerError(this.message);
}
