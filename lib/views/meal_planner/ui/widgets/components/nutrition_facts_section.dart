import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/food_details.dart';

/// 📋 Nutrition facts section
class NutritionFactsSection extends StatelessWidget {
  final Meal meal;
  final NutritionValues nutritionValues;

  const NutritionFactsSection({
    super.key,
    required this.meal,
    required this.nutritionValues,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKey.nutritionValue.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          NutritionRow(
            label: LocaleKey.energy.tr,
            value: '${nutritionValues.calories} cal',
          ),
          const Divider(height: 16),
          NutritionRow(
            label: LocaleKey.carbohydrate.tr,
            value: '${nutritionValues.carbs.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          NutritionRow(
            label: LocaleKey.fat.tr,
            value: '${nutritionValues.fat.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          NutritionRow(
            label: LocaleKey.protein.tr,
            value: '${nutritionValues.protein.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          NutritionRow(
            label: LocaleKey.cholesterol.tr,
            value: meal.cholesterolMg != null
                ? '${meal.cholesterolMg} mg'
                : '--',
          ),
          const Divider(height: 16),
          NutritionRow(
            label: LocaleKey.fiber.tr,
            value: meal.fiberG != null
                ? '${(meal.fiberG! * nutritionValues.calories / meal.calories).toStringAsFixed(2)} g'
                : '--',
          ),
        ],
      ),
    );
  }
}

/// 📌 Single nutrition row
class NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const NutritionRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
