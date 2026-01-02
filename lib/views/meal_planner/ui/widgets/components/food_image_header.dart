import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';

/// 🖼️ Food image header component
class FoodImageHeader extends StatelessWidget {
  final Meal meal;

  const FoodImageHeader({super.key, required this.meal});

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
                meal.name,
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
