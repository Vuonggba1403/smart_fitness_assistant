import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import '../../../../../core/functions/color_extension.dart';

/// Widget hiển thị một row workout với progress
class WhatTrainRow extends StatelessWidget {
  final ExerciseCategory category;
  final int? exerciseCount;
  final Map<String, WorkoutProgress>? progressMap;

  const WhatTrainRow({
    super.key,
    required this.category,
    this.exerciseCount,
    this.progressMap,
  });

  /// Tính phần trăm hoàn thành từ progress map
  double _calculateCompletionPercent() {
    if (progressMap == null || progressMap!.isEmpty) return 0.0;

    final totalExercises = exerciseCount ?? 0;
    final completedExercises = progressMap!.values
        .where((p) => p.isFullyCompleted)
        .length;

    return totalExercises > 0
        ? (completedExercises / totalExercises).clamp(0.0, 1.0)
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionPercent = _calculateCompletionPercent();
    final displayExerciseCount = exerciseCount ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppTheme.gradientColors1(context)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            _buildCategoryImage(completionPercent, theme.cardColor),
            const SizedBox(width: 15),
            Expanded(
              child: _buildCategoryInfo(
                displayExerciseCount,
                completionPercent,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_circle_right_rounded, color: TColor.black),
          ],
        ),
      ),
    );
  }

  /// Build hình ảnh category với check mark nếu hoàn thành
  Widget _buildCategoryImage(double completionPercent, Color cardColor) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.54),
            borderRadius: BorderRadius.circular(40),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: category.imgUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => CustomCircleProgIndicator(),
              errorWidget: (context, url, error) =>
                  Icon(Icons.fitness_center, size: 40, color: TColor.gray),
            ),
          ),
        ),
        if (completionPercent == 1.0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }

  /// Build thông tin category (tên, số bài tập, progress bar)
  Widget _buildCategoryInfo(int exerciseCount, double completionPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.titleEx ?? 'Workout',
          style: TextStyle(
            color: TColor.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$exerciseCount ${LocaleKey.exercises.tr}",
          style: TextStyle(color: TColor.gray, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _buildProgressBar(completionPercent),
      ],
    );
  }

  /// Build progress bar với phần trăm
  Widget _buildProgressBar(double completionPercent) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionPercent,
              minHeight: 6,
              backgroundColor: TColor.gray.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                completionPercent == 1.0 ? Colors.green : TColor.primaryColor1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "${(completionPercent * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            color: TColor.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
