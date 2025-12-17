part of 'meal_planner_cubit.dart';

sealed class MealPlannerState {}

final class MealPlannerInitial extends MealPlannerState {}

final class MealPlannerLoading extends MealPlannerState {}

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
  MealsLoaded({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.currentCalories,
    required this.targetCalories,
  });
}

final class MealAdded extends MealPlannerState {
  final String mealType;
  final String message;
  MealAdded({required this.mealType, required this.message});
}

final class MealRemoved extends MealPlannerState {
  final String mealType;
  MealRemoved(this.mealType);
}

final class MealPlannerError extends MealPlannerState {
  final String message;
  MealPlannerError(this.message);
}
