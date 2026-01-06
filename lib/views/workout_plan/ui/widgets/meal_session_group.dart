import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_plan/ui/widgets/session_list_tiles.dart';

/// Widget nhóm các meal sessions theo loại bữa ăn
class MealSessionGroup extends StatelessWidget {
  final List<MealSession> meals;

  const MealSessionGroup({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final groupedMeals = _groupMealsByType(meals);
    final mealOrder = [
      LocaleKey.breakfast.tr,
      LocaleKey.lunch.tr,
      LocaleKey.dinner.tr,
      LocaleKey.snack.tr,
    ];

    return Column(
      children: mealOrder
          .where((type) => groupedMeals.containsKey(type))
          .map((mealType) => _buildMealGroup(mealType, groupedMeals[mealType]!))
          .toList(),
    );
  }

  /// Group meals theo meal type
  Map<String, List<MealSession>> _groupMealsByType(List<MealSession> meals) {
    final Map<String, List<MealSession>> grouped = {};
    for (var meal in meals) {
      grouped.putIfAbsent(meal.mealType, () => []).add(meal);
    }
    return grouped;
  }

  /// Build một nhóm meal
  Widget _buildMealGroup(String mealType, List<MealSession> mealsInType) {
    final totalCalories = mealsInType.fold<int>(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(mealType, totalCalories),
        ...mealsInType.map((meal) => MealSessionListTile(mealSession: meal)),
        const Divider(height: 1),
      ],
    );
  }

  /// Build header cho mỗi bữa ăn
  Widget _buildHeader(String mealType, int totalCalories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getMealTypeColor(mealType).withOpacity(0.1),
        border: Border(
          left: BorderSide(color: _getMealTypeColor(mealType), width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getMealTypeIcon(mealType),
            color: _getMealTypeColor(mealType),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            mealType,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _getMealTypeColor(mealType),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMealTypeColor(mealType),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalCalories ${LocaleKey.calories.tr}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy màu theo loại bữa ăn
  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case String _ when mealType == LocaleKey.breakfast.tr:
        return Colors.orange;
      case String _ when mealType == LocaleKey.lunch.tr:
        return Colors.green;
      case String _ when mealType == LocaleKey.dinner.tr:
        return Colors.blue;
      case String _ when mealType == LocaleKey.snack.tr:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Lấy icon theo loại bữa ăn
  IconData _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case String _ when mealType == LocaleKey.breakfast.tr:
        return Icons.wb_sunny;
      case String _ when mealType == LocaleKey.lunch.tr:
        return Icons.restaurant;
      case String _ when mealType == LocaleKey.dinner.tr:
        return Icons.nightlight_round;
      case String _ when mealType == LocaleKey.snack.tr:
        return Icons.local_cafe;
      default:
        return Icons.restaurant_menu;
    }
  }
}
