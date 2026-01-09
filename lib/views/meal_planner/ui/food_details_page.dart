import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';

// =====================================================
// 📋 MAIN PAGE
// =====================================================

/// 📋 Chi tiết thông tin dinh dưỡng của món ăn
class FoodDetailsPage extends StatelessWidget {
  final Meal meal;

  const FoodDetailsPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _FoodDetailsCubit(initialServingSize: meal.servingSizeG),
      child: _FoodDetailsView(meal: meal),
    );
  }
}

/// 🎯 Local Cubit for serving size management
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

/// 📱 Main View
class _FoodDetailsView extends StatelessWidget {
  final Meal meal;

  const _FoodDetailsView({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: meal.localizedName),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _FoodImageHeader(meal: meal),
            BlocBuilder<_FoodDetailsCubit, int>(
              builder: (context, servingSize) {
                final nutritionValues = _NutritionValues.calculate(
                  meal: meal,
                  servingSize: servingSize,
                );

                return Column(
                  children: [
                    _MacroCircleSection(nutritionValues: nutritionValues),
                    if (meal.isVerified) const _VerifiedBadge(),
                    _NutritionFactsSection(
                      meal: meal,
                      nutritionValues: nutritionValues,
                    ),
                    if (!meal.isVerified) const _DisclaimerBadge(),
                    const SizedBox(height: 20),
                    _ServingSizeControl(
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

// =====================================================
// 🖼️ FOOD IMAGE HEADER
// =====================================================

class _FoodImageHeader extends StatelessWidget {
  final Meal meal;

  const _FoodImageHeader({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: meal.imageUrl != null
              ? Image.network(
                  meal.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.localizedName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${meal.servingSizeG}g',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      color: Colors.grey.withOpacity(0.3),
      child: const Icon(Icons.image_not_supported, size: 60),
    );
  }
}

// =====================================================
// 📊 MACRO CIRCLE SECTION
// =====================================================

class _MacroCircleSection extends StatelessWidget {
  final _NutritionValues nutritionValues;

  const _MacroCircleSection({required this.nutritionValues});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CalorieCircle(calories: nutritionValues.calories),
          const SizedBox(width: 24),
          _MacroBadges(nutritionValues: nutritionValues),
        ],
      ),
    );
  }
}

class _CalorieCircle extends StatelessWidget {
  final int calories;

  const _CalorieCircle({required this.calories});

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

class _MacroBadges extends StatelessWidget {
  final _NutritionValues nutritionValues;

  const _MacroBadges({required this.nutritionValues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MacroBadge(
          label: '⚡ ${nutritionValues.protein.toStringAsFixed(1)}g',
          percent: nutritionValues.proteinPercent.toStringAsFixed(0),
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _MacroBadge(
          label: '🌾 ${nutritionValues.carbs.toStringAsFixed(1)}g',
          percent: nutritionValues.carbsPercent.toStringAsFixed(0),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _MacroBadge(
          label: '🍯 ${nutritionValues.fat.toStringAsFixed(1)}g',
          percent: nutritionValues.fatPercent.toStringAsFixed(0),
          color: Colors.amber,
        ),
      ],
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const _MacroBadge({
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

// =====================================================
// 🏷️ BADGES (VERIFIED & DISCLAIMER)
// =====================================================

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LocaleKey.confirmedByNutritionTeam.tr,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerBadge extends StatelessWidget {
  const _DisclaimerBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LocaleKey.infoCorrect.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 📋 NUTRITION FACTS SECTION
// =====================================================

class _NutritionFactsSection extends StatelessWidget {
  final Meal meal;
  final _NutritionValues nutritionValues;

  const _NutritionFactsSection({
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
          _NutritionRow(
            label: LocaleKey.energy.tr,
            value: '${nutritionValues.calories} cal',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: LocaleKey.carbohydrate.tr,
            value: '${nutritionValues.carbs.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: LocaleKey.fat.tr,
            value: '${nutritionValues.fat.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: LocaleKey.protein.tr,
            value: '${nutritionValues.protein.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: LocaleKey.cholesterol.tr,
            value: meal.cholesterolMg != null
                ? '${meal.cholesterolMg} mg'
                : '--',
          ),
          const Divider(height: 16),
          _NutritionRow(
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

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow({required this.label, required this.value});

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

// =====================================================
// 🔧 SERVING SIZE CONTROL
// =====================================================

class _ServingSizeControl extends StatelessWidget {
  final int servingSize;
  final Function(int) onUpdateServingSize;
  final Function(int) onSetServingSize;

  const _ServingSizeControl({
    required this.servingSize,
    required this.onUpdateServingSize,
    required this.onSetServingSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKey.customServing.tr,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => onUpdateServingSize(-10),
                  icon: const Icon(Icons.remove, size: 20),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '$servingSize')
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: '$servingSize'.length),
                      ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null) {
                        onSetServingSize(intValue);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => onUpdateServingSize(10),
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'gram',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ➕ ADD MEAL BUTTON
// =====================================================

class _AddMealButton extends StatelessWidget {
  final Meal meal;
  final _NutritionValues nutritionValues;

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
    print('============ ADD MEAL BUTTON CLICKED ============');
    print('Meal ID: ${meal.id}');
    print('Meal Name: ${meal.name}');
    print('Meal Barcode: ${meal.barcode}');

    final hour = DateTime.now().hour;
    final mealType = _determineMealType(hour);
    final servingSize = context.read<_FoodDetailsCubit>().state;

    debugPrint('🍽️ _handleAddMeal called - Hour: $hour, MealType: $mealType');
    debugPrint('🍽️ Meal: ${meal.name}, Serving: $servingSize');

    context.read<MealPlannerCubit>().addMealToType(mealType, {
      'id': meal.id,
      'name': meal.name,
      'name_en': meal.nameEn,
      'calories': nutritionValues.calories, // Scaled calories cho user_meals
      'protein': nutritionValues.protein,
      'carbs': nutritionValues.carbs,
      'fat': nutritionValues.fat,
      'serving_size': servingSize,
      // ✅ Nutrition values gốc cho meals table (per 100g)
      'base_calories': meal.calories,
      'base_protein': meal.proteinG,
      'base_carbs': meal.carbsG,
      'base_fat': meal.fatG,
      'fiber': meal.fiberG ?? 0.0,
      'cholesterol': meal.cholesterolMg ?? 0.0,
      'is_verified': meal.isVerified,
      'image_url': meal.imageUrl,
      'barcode': meal.barcode,
    }, DateTime.now());

    debugPrint('🍽️ addMealToType called successfully');
    AppSnackBar.success(
      context,
      '${meal.localizedName} ${LocaleKey.addedToMeal.tr}',
    );

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
// 🧮 NUTRITION VALUES CALCULATOR
// =====================================================

class _NutritionValues {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  const _NutritionValues({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  factory _NutritionValues.calculate({
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

    return _NutritionValues(
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
