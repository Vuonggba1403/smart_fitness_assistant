import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';

/// 📋 Chi tiết thông tin dinh dưỡng của món ăn
class FoodDetails extends StatefulWidget {
  final Meal meal;

  const FoodDetails({super.key, required this.meal});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  int _servingSize = 100;

  /// 🧮 Helper: Tính giá trị dinh dưỡng theo serving size
  NutritionValues get _nutritionValues =>
      NutritionValues.calculate(meal: widget.meal, servingSize: _servingSize);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(theme),
            _buildMacroCircleSection(theme),
            if (widget.meal.isVerified) _buildVerifiedBadge(theme),
            _buildNutritionFactsSection(theme),
            _buildMoreInfoButton(theme),
            if (!widget.meal.isVerified) _buildDisclaimerBadge(theme),
            const SizedBox(height: 20),
            _buildServingSizeControl(theme),
            const SizedBox(height: 30),
            _buildAddButton(theme),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🧭 AppBar với nút back và favorite
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: const BackButton(),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Implement favorite feature
          },
        ),
      ],
    );
  }

  /// 🖼️ Phần hiển thị ảnh và tên món ăn
  Widget _buildImageSection(ThemeData theme) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: widget.meal.imageUrl != null
              ? Image.network(
                  widget.meal.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meal.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.meal.servingSizeG}g',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📦 Placeholder khi không có ảnh
  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      color: Colors.grey.shade700,
      child: const Icon(Icons.image_not_supported, size: 60),
    );
  }

  /// 📊 Phần hiển thị vòng tròn calories và badges macro
  Widget _buildMacroCircleSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCalorieCircle(),
          const SizedBox(width: 24),
          _buildMacroBadges(),
        ],
      ),
    );
  }

  /// 🟡 Vòng tròn hiển thị calories
  Widget _buildCalorieCircle() {
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
                '${_nutritionValues.calories}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Cal', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏷️ Các badge hiển thị macro
  Widget _buildMacroBadges() {
    return Column(
      children: [
        _MacroBadge(
          label: '⚡ ${_nutritionValues.protein.toStringAsFixed(1)}g',
          percent: _nutritionValues.proteinPercent.toStringAsFixed(0),
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _MacroBadge(
          label: '🌾 ${_nutritionValues.carbs.toStringAsFixed(1)}g',
          percent: _nutritionValues.carbsPercent.toStringAsFixed(0),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _MacroBadge(
          label: '🍯 ${_nutritionValues.fat.toStringAsFixed(1)}g',
          percent: _nutritionValues.fatPercent.toStringAsFixed(0),
          color: Colors.amber,
        ),
      ],
    );
  }

  /// ✅ Badge xác thực
  Widget _buildVerifiedBadge(ThemeData theme) {
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
                'Được xác nhận bởi đội ngũ dinh dưỡng Wao',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⚠️ Badge cảnh báo chưa xác thực
  Widget _buildDisclaimerBadge(ThemeData theme) {
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
                'Thông tin này có đúng không?',
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

  /// 📋 Phần hiển thị thông tin dinh dưỡng chi tiết
  Widget _buildNutritionFactsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá trị dinh dưỡng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _NutritionRow(
            label: 'Năng lượng',
            value: '${_nutritionValues.calories} cal',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: 'Đường bột (carb)',
            value: '${_nutritionValues.carbs.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: 'Chất béo (fat)',
            value: '${_nutritionValues.fat.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: 'Chất đạm (protein)',
            value: '${_nutritionValues.protein.toStringAsFixed(1)} g',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: 'Cholesterol',
            value: widget.meal.cholesterolMg != null
                ? '${widget.meal.cholesterolMg} mg'
                : '--',
          ),
          const Divider(height: 16),
          _NutritionRow(
            label: 'Chất xơ',
            value: widget.meal.fiberG != null
                ? '${(widget.meal.fiberG! * _servingSize / 100).toStringAsFixed(2)} g'
                : '--',
          ),
        ],
      ),
    );
  }

  /// 📌 Nút hiển thị thêm thông tin
  Widget _buildMoreInfoButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          // TODO: Show more info
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Hiển thị thêm thông tin',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔧 Control điều chỉnh serving size
  Widget _buildServingSizeControl(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Khẩu phần tùy chỉnh',
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
                  onPressed: () => _updateServingSize(-10),
                  icon: const Icon(Icons.remove, size: 20),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '$_servingSize'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _servingSize = int.tryParse(value) ?? 100;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _updateServingSize(10),
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

  /// 🔄 Cập nhật serving size
  void _updateServingSize(int delta) {
    setState(() {
      _servingSize = (_servingSize + delta).clamp(10, 9999);
    });
  }

  /// ➕ Nút thêm món ăn vào meal planner
  Widget _buildAddButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleAddMeal,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Thêm vào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Xử lý thêm món ăn
  void _handleAddMeal() {
    final hour = DateTime.now().hour;
    final mealType = _determineMealType(hour);

    context.read<MealPlannerCubit>().addMealToType(mealType, {
      'id': widget.meal.id,
      'name': widget.meal.name,
      'calories': _nutritionValues.calories,
      'protein': _nutritionValues.protein,
      'carbs': _nutritionValues.carbs,
      'fat': _nutritionValues.fat,
      'serving_size': _servingSize,
    }, DateTime.now());

    AppSnackBar.success(context, '${widget.meal.name} đã được thêm vào');
    Navigator.pop(context);
  }

  /// 🕐 Xác định loại bữa ăn dựa vào giờ
  String _determineMealType(int hour) {
    if (hour >= 6 && hour < 10) return 'breakfast';
    if (hour >= 10 && hour < 14) return 'lunch';
    if (hour >= 14 && hour <= 22) return 'dinner';
    return 'snack';
  }
}

// =====================================================
// 📦 HELPER CLASSES (Separation of Concerns)
// =====================================================

/// 🧮 Class tính toán giá trị dinh dưỡng
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

  /// ✅ Factory: Tính toán từ meal và serving size
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

/// 🏷️ Widget hiển thị macro badge
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
              style: const TextStyle(
                color: Colors.white,
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

/// 📌 Widget hiển thị hàng thông tin dinh dưỡng
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
