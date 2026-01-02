import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/food_details.dart';

/// 📊 Macro circle section with calorie circle and macro badges
class MacroCircleSection extends StatelessWidget {
  final NutritionValues nutritionValues;

  const MacroCircleSection({super.key, required this.nutritionValues});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CalorieCircle(calories: nutritionValues.calories),
          const SizedBox(width: 24),
          MacroBadges(nutritionValues: nutritionValues),
        ],
      ),
    );
  }
}

/// 🟡 Calorie circle widget
class CalorieCircle extends StatelessWidget {
  final int calories;

  const CalorieCircle({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                Color.lerp(Colors.blue, Colors.orange, 0.5)!,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$calories',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(LocaleKey.cal.tr, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🏷️ Macro badges group
class MacroBadges extends StatelessWidget {
  final NutritionValues nutritionValues;

  const MacroBadges({super.key, required this.nutritionValues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MacroBadge(
          label: '⚡ ${nutritionValues.protein.toStringAsFixed(1)}g',
          percent: nutritionValues.proteinPercent.toStringAsFixed(0),
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        MacroBadge(
          label: '🌾 ${nutritionValues.carbs.toStringAsFixed(1)}g',
          percent: nutritionValues.carbsPercent.toStringAsFixed(0),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        MacroBadge(
          label: '🍯 ${nutritionValues.fat.toStringAsFixed(1)}g',
          percent: nutritionValues.fatPercent.toStringAsFixed(0),
          color: Colors.amber,
        ),
      ],
    );
  }
}

/// 🏷️ Single macro badge
class MacroBadge extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const MacroBadge({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$percent%',
              style: TextStyle(
                color: TColor.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
