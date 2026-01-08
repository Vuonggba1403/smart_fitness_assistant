import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

/// Card widget for displaying individual exercise item
class ExerciseCard extends StatelessWidget {
  final ExerciseItem exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return InkWell(
      onTap: () => ExerciseDetailBottomSheet.show(context, exercise),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.gradientColors2(Get.context!),
          ),
          border: Border.all(color: TColor.primaryColor1, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: TColor.primaryColor2, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                  key: ValueKey('img_${exercise.id}'),
                  imageUrl: exercise.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  memCacheWidth: 180,
                  memCacheHeight: 180,
                  maxWidthDiskCache: 300,
                  maxHeightDiskCache: 300,
                  placeholder: (context, url) => CustomCircleProgIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.fitness_center, size: 30, color: TColor.gray),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "4 ${LocaleKey.sets.tr} x 8 ${LocaleKey.reps.tr}",
                    style: TextStyle(
                      color: textColor?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textColor?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
