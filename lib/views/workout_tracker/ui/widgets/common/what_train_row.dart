import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/workout_progress.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import '../../../../../core/functions/colo_extension.dart';

/// Widget hiển thị một row của workout/exercise
/// Sử dụng ExerciseCategory model từ Supabase
class WhatTrainRow extends StatelessWidget {
  final ExerciseCategory category;
  final int? exerciseCount;
  final int? durationMins; // ✅ Giữ lại để tương thích nhưng không dùng
  final Map<String, WorkoutProgress>? progressMap; // ✅ Thêm progress

  const WhatTrainRow({
    super.key,
    required this.category,
    this.exerciseCount,
    this.durationMins,
    this.progressMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    final displayExerciseCount = exerciseCount ?? 0;

    // ✅ Tính % hoàn thành từ progress thực tế
    double completionPercent = 0.0;
    if (progressMap != null && progressMap!.isNotEmpty) {
      final totalExercises = displayExerciseCount;
      final completedExercises = progressMap!.values
          .where((p) => p.isFullyCompleted)
          .length;
      completionPercent = totalExercises > 0
          ? (completedExercises / totalExercises).clamp(0.0, 1.0)
          : 0.0;
    }

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
            // ✅ Thêm checkmark nếu hoàn thành 100%
            Stack(
              children: [
                Hero(
                  tag: 'workout_${category.imgUrl}',
                  child: Container(
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
                        // Hiển thị loading progress khi đang tải ảnh
                        placeholder: (context, url) =>
                            CustomCircleProgIndicator(),
                        // Hiển thị icon khi có lỗi load ảnh
                        errorWidget: (context, url, error) => Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: TColor.gray,
                        ),
                      ),
                    ),
                  ),
                ), // ✅ Đóng Hero widget
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
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên bài tập từ database
                  Text(
                    category.titleEx ?? 'Workout',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ Chỉ hiển thị số bài tập
                  Text(
                    "$displayExerciseCount ${LocaleKey.exercises.tr}",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completionPercent,
                            minHeight: 6,
                            backgroundColor: TColor.gray.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              completionPercent == 1.0
                                  ? Colors.green
                                  : TColor.primaryColor1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ✅ Hiển thị % chính xác (không làm tròn)
                      Text(
                        "${(completionPercent * 100).toStringAsFixed(0)}%",
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
            // Icon mũi tên để chỉ ra có thể click
            Icon(Icons.arrow_circle_right_rounded, color: TColor.black),
          ],
        ),
      ),
    );
  }
}
