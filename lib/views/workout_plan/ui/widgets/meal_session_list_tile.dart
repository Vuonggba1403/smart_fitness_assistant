import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';

/// Widget hiển thị một meal session trong list
class MealSessionListTile extends StatelessWidget {
  final MealSession mealSession;

  const MealSessionListTile({super.key, required this.mealSession});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLeading(),
      title: Text(
        mealSession.meal.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: _buildSubtitle(),
    );
  }

  /// Build leading image
  Widget _buildLeading() {
    if (mealSession.meal.imageUrl == null) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        mealSession.meal.imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant, color: Colors.grey),
    );
  }

  /// Build subtitle với thông tin calories và macros
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '${mealSession.totalCalories} cal • Khẩu phần: ${mealSession.servingSize}x',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          'P: ${(mealSession.meal.proteinG * mealSession.servingSize).toStringAsFixed(1)}g • '
          'C: ${(mealSession.meal.carbsG * mealSession.servingSize).toStringAsFixed(1)}g • '
          'F: ${(mealSession.meal.fatG * mealSession.servingSize).toStringAsFixed(1)}g',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
