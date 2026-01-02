import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/components/food_image_header.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/components/macro_circle_section.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/components/nutrition_badges.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/components/nutrition_facts_section.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/components/serving_size_control.dart';

/// 📋 Chi tiết thông tin dinh dưỡng của món ăn
class FoodDetails extends StatelessWidget {
  final Meal meal;

  const FoodDetails({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _FoodDetailsCubit(initialServingSize: meal.servingSizeG),
      child: _FoodDetailsView(meal: meal),
    );
  }
}

/// 🎯 Cubit riêng cho FoodDetails (local state)
class _FoodDetailsCubit extends Cubit<int> {
  _FoodDetailsCubit({required int initialServingSize})
    : super(initialServingSize);

  void updateServingSize(int delta) {
    emit((state + delta).clamp(10, 9999));
  }

  void setServingSize(int value) {
    emit(value.clamp(10, 9999));
  }
}

/// 📱 View của FoodDetails
class _FoodDetailsView extends StatelessWidget {
  final Meal meal;

  const _FoodDetailsView({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: meal.name),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FoodImageHeader(meal: meal),
            BlocBuilder<_FoodDetailsCubit, int>(
              builder: (context, servingSize) {
                final nutritionValues = NutritionValues.calculate(
                  meal: meal,
                  servingSize: servingSize,
                );

                return Column(
                  children: [
                    MacroCircleSection(nutritionValues: nutritionValues),
                    if (meal.isVerified) const VerifiedBadge(),
                    NutritionFactsSection(
                      meal: meal,
                      nutritionValues: nutritionValues,
                    ),
                    // const _MoreInfoButton(),
                    if (!meal.isVerified) const DisclaimerBadge(),
                    const SizedBox(height: 20),
                    ServingSizeControl(
                      servingSize: servingSize,
                      onUpdateServingSize: (delta) => context
                          .read<_FoodDetailsCubit>()
                          .updateServingSize(delta),
                      onSetServingSize: (value) => context
                          .read<_FoodDetailsCubit>()
                          .setServingSize(value),
                    ),
                    const SizedBox(height: 30),
                    _AddMealButton(
                      meal: meal,
                      nutritionValues: nutritionValues,
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ➕ Add meal button
class _AddMealButton extends StatelessWidget {
  final Meal meal;
  final NutritionValues nutritionValues;

  const _AddMealButton({required this.meal, required this.nutritionValues});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleAddMeal(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            LocaleKey.addTo.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColor.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddMeal(BuildContext context) {
    final hour = DateTime.now().hour;
    final mealType = _determineMealType(hour);
    final servingSize = context.read<_FoodDetailsCubit>().state;

    context.read<MealPlannerCubit>().addMealToType(mealType, {
      'id': meal.id,
      'name': meal.name,
      'calories': nutritionValues.calories,
      'protein': nutritionValues.protein,
      'carbs': nutritionValues.carbs,
      'fat': nutritionValues.fat,
      'serving_size': servingSize,
    }, DateTime.now());

    AppSnackBar.success(context, '${meal.name} ${LocaleKey.addedToMeal.tr}');

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  String _determineMealType(int hour) {
    if (hour >= 6 && hour < 10) return 'breakfast';
    if (hour >= 10 && hour < 14) return 'lunch';
    if (hour >= 14 && hour <= 22) return 'dinner';
    return 'snack';
  }
}

// =====================================================
// 📦 HELPER CLASSES
// =====================================================

/// 🧮 Nutrition values calculator
class NutritionValues {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  const NutritionValues({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  factory NutritionValues.calculate({
    required Meal meal,
    required int servingSize,
  }) {
    final ratio = servingSize / 100;
    final calories = (meal.calories * ratio).toInt();
    final protein = meal.proteinG * ratio;
    final carbs = meal.carbsG * ratio;
    final fat = meal.fatG * ratio;

    final totalCalories = calories > 0 ? calories : 1;
    final proteinPercent = (protein * 4) / totalCalories * 100;
    final carbsPercent = (carbs * 4) / totalCalories * 100;
    final fatPercent = (fat * 9) / totalCalories * 100;

    return NutritionValues(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
    );
  }
}
