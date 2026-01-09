import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

/// ✨ Gộp workout và meal session list tiles với shared components

// ========== Workout Session List Tile ==========
class WorkoutSessionListTile extends StatelessWidget {
  final WorkoutSession workout;

  const WorkoutSessionListTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _SessionImage(
        imageUrl: workout.exercise.imageUrl,
        placeholderIcon: Icons.fitness_center,
      ),
      title: Text(
        workout.exercise.localizedTitle,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: _WorkoutSubtitle(workout: workout),
      trailing: IconButton(
        icon: Icon(Icons.info_outline, color: TColor.primaryColor1, size: 24),
        onPressed: () {
          ExerciseDetailBottomSheet.show(context, workout.exercise);
        },
        tooltip: LocaleKey.viewDetails.tr,
      ),
    );
  }
}

// ========== Meal Session List Tile ==========
class MealSessionListTile extends StatelessWidget {
  final MealSession mealSession;

  const MealSessionListTile({super.key, required this.mealSession});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _SessionImage(
        imageUrl: mealSession.meal.imageUrl,
        placeholderIcon: Icons.restaurant,
      ),
      title: Text(
        mealSession.meal.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: _MealSubtitle(mealSession: mealSession),
    );
  }
}

// ========== Shared Components ==========

/// Generic session image with placeholder
class _SessionImage extends StatelessWidget {
  final String? imageUrl;
  final IconData placeholderIcon;

  const _SessionImage({required this.imageUrl, required this.placeholderIcon});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(placeholderIcon, color: Colors.grey),
    );
  }
}

/// Workout session subtitle
class _WorkoutSubtitle extends StatelessWidget {
  final WorkoutSession workout;

  const _WorkoutSubtitle({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '${workout.sets} sets × ${workout.reps} reps'
          '${workout.durationMinutes != null ? " • ${workout.durationMinutes} ${LocaleKey.minutes.tr}" : ""}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          workout.exercise.muscleGroupsString,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Meal session subtitle
class _MealSubtitle extends StatelessWidget {
  final MealSession mealSession;

  const _MealSubtitle({required this.mealSession});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '${mealSession.totalCalories} ${LocaleKey.calories.tr} • ${LocaleKey.servingSize.tr}: ${mealSession.servingSize}x',
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
