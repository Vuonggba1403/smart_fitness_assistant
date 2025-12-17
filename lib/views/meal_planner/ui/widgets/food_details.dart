import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';

class FoodDetails extends StatefulWidget {
  final Meal meal;

  const FoodDetails({super.key, required this.meal});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  int _servingSize = 100;

  /// 🔄 Tính toán macros theo serving size
  double get _proteinValue => (widget.meal.proteinG * _servingSize) / 100;
  double get _carbsValue => (widget.meal.carbsG * _servingSize) / 100;
  double get _fatValue => (widget.meal.fatG * _servingSize) / 100;
  int get _caloriesValue => (widget.meal.calories * _servingSize) ~/ 100;

  /// 🥇 Tính phần trăm macro
  double get _proteinPercent => (_proteinValue * 4) / _caloriesValue * 100;
  double get _carbsPercent => (_carbsValue * 4) / _caloriesValue * 100;
  double get _fatPercent => (_fatValue * 9) / _caloriesValue * 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🖼️ FOOD IMAGE + HEADER
            _buildImageSection(theme),

            /// 📊 MACRO CIRCLE + BADGES
            _buildMacroCircleSection(theme),

            /// ✅ VERIFIED BADGE
            if (widget.meal.isVerified)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                          'Được xác nhận bởi đội ngũ định dưỡng Wao',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// 📋 NUTRITION FACTS
            Padding(
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

                  /// 🔥 CALORIES
                  _buildNutritionRow(
                    theme,
                    'Năng lượng',
                    '$_caloriesValue cal',
                  ),
                  const Divider(height: 16),

                  /// 🌾 CARBS
                  _buildNutritionSection(
                    theme,
                    'Đường bột (carb)',
                    '${_carbsValue.toStringAsFixed(1)} g',
                    [
                      _buildSubNutrition(theme, 'Chất xơ', '-'),
                      _buildSubNutrition(theme, 'Đường', '-'),
                    ],
                  ),
                  const Divider(height: 16),

                  /// 🥓 FAT
                  _buildNutritionRow(
                    theme,
                    'Chất béo (fat)',
                    '${_fatValue.toStringAsFixed(1)} g',
                  ),
                  const Divider(height: 16),

                  /// ⚡ PROTEIN
                  _buildNutritionRow(
                    theme,
                    'Chất đạm (protein)',
                    '${_proteinValue.toStringAsFixed(1)} g',
                  ),
                  const Divider(height: 16),

                  /// 💉 CHOLESTEROL
                  _buildNutritionRow(
                    theme,
                    'Cholesterol',
                    widget.meal.cholesterolMg != null
                        ? '${widget.meal.cholesterolMg} mg'
                        : '--',
                  ),
                  const Divider(height: 16),

                  /// 🧂 FIBER
                  _buildNutritionRow(
                    theme,
                    'Muối',
                    widget.meal.fiberG != null
                        ? '${(widget.meal.fiberG! * _servingSize / 100).toStringAsFixed(2)} g'
                        : '--',
                  ),
                ],
              ),
            ),

            /// 📌 MORE INFO BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

            const SizedBox(height: 20),

            /// ⚠️ DISCLAIMER
            if (!widget.meal.isVerified)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thông tin này có dùng không?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// 🔧 SERVING SIZE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Khẩu phần tuy chính',
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
                          onPressed: () {
                            setState(() {
                              if (_servingSize > 10) _servingSize -= 10;
                            });
                          },
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: TextEditingController(
                              text: '$_servingSize',
                            ),
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
                          onPressed: () {
                            setState(() {
                              _servingSize += 10;
                            });
                          },
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'gram',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ➕ ADD BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add meal to planner
                  },
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
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🖼️ IMAGE + NAME SECTION
  Widget _buildImageSection(ThemeData theme) {
    return Column(
      children: [
        /// Image
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade700,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                )
              : Container(
                  height: 250,
                  color: Colors.grey.shade700,
                  child: const Icon(Icons.image_not_supported),
                ),
        ),

        /// Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

  /// 📊 MACRO CIRCLE + BADGES
  Widget _buildMacroCircleSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🟡 CALORIE CIRCLE
              SizedBox(
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
                          Color.lerp(Colors.blue, Colors.orange, 0.5) ??
                              Colors.orange,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_caloriesValue',
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
              ),

              const SizedBox(width: 24),

              /// 📊 MACRO BADGES
              Column(
                children: [
                  _buildMacroBadge(
                    '⚡ ${_proteinValue.toStringAsFixed(1)}g',
                    _proteinPercent.toStringAsFixed(0),
                    Colors.red,
                    'CHẤT ĐẠM',
                  ),
                  const SizedBox(height: 12),
                  _buildMacroBadge(
                    '🌾 ${_carbsValue.toStringAsFixed(1)}g',
                    _carbsPercent.toStringAsFixed(0),
                    Colors.blue,
                    'ĐƯỜNG BỘT',
                  ),
                  const SizedBox(height: 12),
                  _buildMacroBadge(
                    '🍯 ${_fatValue.toStringAsFixed(1)}g',
                    _fatPercent.toStringAsFixed(0),
                    Colors.amber,
                    'CHẤT BÉO',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏷️ MACRO BADGE
  Widget _buildMacroBadge(
    String label,
    String percent,
    Color color,
    String name,
  ) {
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

  /// 📌 NUTRITION ROW
  Widget _buildNutritionRow(ThemeData theme, String label, String value) {
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

  /// 📋 NUTRITION SECTION (với sub-items)
  Widget _buildNutritionSection(
    ThemeData theme,
    String label,
    String value,
    List<Widget> subItems,
  ) {
    return Column(
      children: [
        _buildNutritionRow(theme, label, value),
        const SizedBox(height: 12),
        ...subItems,
      ],
    );
  }

  /// 📌 SUB NUTRITION
  Widget _buildSubNutrition(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
