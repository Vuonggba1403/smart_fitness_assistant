import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import '../../../../../core/functions/color_extension.dart';

/// Component hiển thị thẻ danh mục bài tập kèm tiến độ hoàn thành.
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

  /// Tính toán tỷ lệ hoàn thành bài tập (0.0 -> 1.0)
  double get _completionPercent {
    if (progressMap == null ||
        progressMap!.isEmpty ||
        exerciseCount == null ||
        exerciseCount == 0) {
      return 0.0;
    }
    final completedCount = progressMap!.values
        .where((p) => p.isFullyCompleted)
        .length;
    return (completedCount / exerciseCount!).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final percent = _completionPercent;
    final isDone = percent == 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientColors1(context)),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Image Section với Badge hoàn thành
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.54),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: category.imgUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const CustomCircleProgIndicator(),
                    errorWidget: (_, __, ___) => Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: TColor.gray,
                    ),
                  ),
                ),
              ),
              if (isDone)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),

          // 2. Info & Progress Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.localizedTitleEx,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${exerciseCount ?? 0} ${LocaleKey.exercises.tr}",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),

                // Progress Bar Row
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: TColor.gray.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDone ? Colors.green : TColor.primaryColor1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${(percent * 100).toInt()}%",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
          Icon(Icons.arrow_circle_right_rounded, color: textColor, size: 30),
        ],
      ),
    );
  }
}
