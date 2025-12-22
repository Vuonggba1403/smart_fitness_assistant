part of 'meal_planner_cubit.dart';

sealed class MealPlannerState {}

/// 🔵 State khởi tạo
final class MealPlannerInitial extends MealPlannerState {}

/// ⏳ State đang load
final class MealPlannerLoading extends MealPlannerState {}

/// 📅 State cập nhật date time
final class DateTimeUpdated extends MealPlannerState {
  final DateTime selectedDateTime;
  DateTimeUpdated(this.selectedDateTime);
}

/// ✅ State load meals thành công
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

/// ➕ State thêm meal thành công
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

/// 🗑️ State xóa meal thành công
final class MealRemoved extends MealPlannerState {
  final String mealType;
  MealRemoved(this.mealType);
}

/// ❌ State lỗi
final class MealPlannerError extends MealPlannerState {
  final String message;
  MealPlannerError(this.message);
}
