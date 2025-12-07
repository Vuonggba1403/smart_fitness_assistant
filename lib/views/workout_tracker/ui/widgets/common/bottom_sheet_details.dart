import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Bottom sheet hiển thị chi tiết exercise
/// ✅ Tối ưu: Nhận ExerciseItem đã load sẵn, không cần fetch lại data
class ExerciseDetailBottomSheet extends StatelessWidget {
  final ExerciseItem exercise;

  const ExerciseDetailBottomSheet({super.key, required this.exercise});

  /// ✅ Hiển thị bottom sheet từ ExerciseItem đã load
  /// Data đã được load từ WorkoutDetailView, không cần fetch lại
  static void show(BuildContext context, ExerciseItem exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailBottomSheet(exercise: exercise),
    );
  }

  /// Hiển thị bottom sheet từ Map (backward compatibility)
  static void showFromMap(
    BuildContext context,
    Map<String, dynamic> exerciseMap,
  ) {
    final exercise = ExerciseItem.fromJson(exerciseMap);
    show(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final media = MediaQuery.of(context).size;

    // ✅ Sử dụng data từ exercise đã được truyền vào
    // Không cần FutureBuilder, StreamBuilder hay bất kỳ async call nào
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header với drag indicator và title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drag indicator
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    exercise.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // ❌ BỎ phần hiển thị classify label từ exercise
                  // Vì classify đã chuyển sang category
                ],
              ),
            ),

            // Content - ✅ Render ngay từ data đã có
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (exercise.description.isNotEmpty) ...[
                      Text(
                        LocaleKey.des.tr,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exercise.description,
                        style: TextStyle(
                          color: textColor?.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Exercise Image - ✅ Load từ cache với optimized config
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        key: ValueKey(
                          'detail_img_${exercise.id}',
                        ), // ✅ Unique key
                        imageUrl: exercise.imageUrl,
                        width: double.infinity,
                        height: media.height * 0.25,
                        fit: BoxFit.cover,
                        memCacheWidth: (media.width * 2)
                            .toInt(), // ✅ 2x width for high quality
                        memCacheHeight: (media.height * 0.5).toInt(),
                        maxWidthDiskCache: 1200, // ✅ Cache high quality
                        maxHeightDiskCache: 1200,
                        placeholder: (context, url) =>
                            CustomCircleProgIndicator(),
                        errorWidget: (context, url, error) => Container(
                          height: media.height * 0.25,
                          decoration: BoxDecoration(
                            color: textColor?.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: TColor.gray,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Devices - ✅ Hiển thị từ data đã load
                    Text(
                      LocaleKey.device.tr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    exercise.hasEquipment
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.devices.asMap().entries.map((
                              entry,
                            ) {
                              final idx = entry.key;
                              final device = entry.value;
                              return _buildChip(
                                label: device.name,
                                isSelected: true,
                                textColor: textColor,
                                key: ValueKey(
                                  'device_${exercise.id}_$idx',
                                ), // ✅ Unique key
                              );
                            }).toList(),
                          )
                        : _buildChip(
                            label: LocaleKey.noEquipment.tr,
                            isSelected: false,
                            textColor: textColor,
                          ),

                    const SizedBox(height: 24),

                    // Muscle Groups - ✅ Hiển thị từ data đã load
                    Text(
                      LocaleKey.muscleGroup.tr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.muscleGroups.asMap().entries.map((
                        entry,
                      ) {
                        final idx = entry.key;
                        final group = entry.value;
                        return _buildChip(
                          label: group,
                          isSelected: true,
                          textColor: textColor,
                          key: ValueKey(
                            'muscle_${exercise.id}_$idx',
                          ), // ✅ Unique key
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Muscle Groups Image - ✅ Hiển thị ảnh đầy đủ không bị scale
                    if (exercise.imgMuscleGroups != null &&
                        exercise.imgMuscleGroups!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: textColor?.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          // border: Border.all(color: Colors.black),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),

                          child: CachedNetworkImage(
                            key: ValueKey('muscle_img_${exercise.id}'),
                            imageUrl: exercise.imgMuscleGroups!,
                            fit: BoxFit
                                .fitWidth, // ✅ Fit theo chiều rộng, chiều cao tự động
                            memCacheWidth: (media.width * 2).toInt(),
                            maxWidthDiskCache: 1200,
                            placeholder: (context, url) => Container(
                              height: 200,
                              child: Center(child: CustomCircleProgIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: TColor.gray,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Không tìm thấy ảnh',
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RoundButton(
                  title: LocaleKey.completeEx.tr,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build chip widget
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color? textColor,
    Key? key, // ✅ Accept key
  }) {
    return Container(
      key: key, // ✅ Pass key
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? TColor.primaryColor1.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? TColor.primaryColor1
              : TColor.gray.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(color: TColor.primaryColor1, width: 1.5),
                color: TColor.primaryColor1,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? TColor.primaryColor1 : textColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
