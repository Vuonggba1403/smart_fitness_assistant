import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Bottom sheet hiển thị chi tiết exercise đã được optimize
class ExerciseDetailBottomSheet extends StatelessWidget {
  final ExerciseItem exercise;

  const ExerciseDetailBottomSheet({super.key, required this.exercise});

  /// Hiển thị bottom sheet từ ExerciseItem
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
            _buildHeader(textColor),
            _buildContent(scrollController, media, textColor),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Build header với drag indicator và title
  Widget _buildHeader(Color? textColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: TColor.gray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.localizedTitle,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build nội dung scrollable
  Widget _buildContent(
    ScrollController scrollController,
    Size media,
    Color? textColor,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.localizedDescription.isNotEmpty)
              _buildDescription(textColor),
            _buildExerciseImage(media, textColor),
            const SizedBox(height: 24),
            _buildDevicesSection(textColor),
            const SizedBox(height: 24),
            _buildMuscleGroupsSection(textColor),
            const SizedBox(height: 24),
            if (exercise.imgMuscleGroups != null &&
                exercise.imgMuscleGroups!.isNotEmpty)
              _buildMuscleGroupImage(media, textColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build phần mô tả
  Widget _buildDescription(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          exercise.localizedDescription,
          style: TextStyle(
            color: textColor?.withOpacity(0.8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build hình ảnh exercise
  Widget _buildExerciseImage(Size media, Color? textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CachedNetworkImage(
        key: ValueKey('detail_img_${exercise.id}'),
        imageUrl: exercise.imageUrl,
        width: double.infinity,
        height: media.height * 0.25,
        fit: BoxFit.cover,
        memCacheWidth: (media.width * 2).toInt(),
        memCacheHeight: (media.height * 0.5).toInt(),
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        placeholder: (context, url) => CustomCircleProgIndicator(),
        errorWidget: (context, url, error) => Container(
          height: media.height * 0.25,
          decoration: BoxDecoration(
            color: textColor?.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.fitness_center, size: 60, color: TColor.gray),
        ),
      ),
    );
  }

  /// Build section thiết bị
  Widget _buildDevicesSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                children: exercise.devices.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final device = entry.value;
                  return _buildChip(
                    label: device.localizedName,
                    isSelected: true,
                    textColor: textColor,
                    key: ValueKey('device_${exercise.id}_$idx'),
                  );
                }).toList(),
              )
            : _buildChip(
                label: LocaleKey.noEquipment.tr,
                isSelected: false,
                textColor: textColor,
              ),
      ],
    );
  }

  /// Build section nhóm cơ
  Widget _buildMuscleGroupsSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: exercise.localizedMuscleGroups.asMap().entries.map((entry) {
            final idx = entry.key;
            final group = entry.value;
            return _buildChip(
              label: group,
              isSelected: true,
              textColor: textColor,
              key: ValueKey('muscle_${exercise.id}_$idx'),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build hình ảnh nhóm cơ
  Widget _buildMuscleGroupImage(Size media, Color? textColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: textColor?.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
          key: ValueKey('muscle_img_${exercise.id}'),
          imageUrl: exercise.imgMuscleGroups!,
          fit: BoxFit.fitWidth,
          memCacheWidth: (media.width * 2).toInt(),
          maxWidthDiskCache: 1200,
          placeholder: (context, url) => SizedBox(
            height: 200,
            child: Center(child: CustomCircleProgIndicator()),
          ),
          errorWidget: (context, url, error) => SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 60, color: TColor.gray),
                  const SizedBox(height: 8),
                  Text(
                    LocaleKey.imageNotFound.tr,
                    style: TextStyle(color: TColor.gray, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build footer với nút đóng
  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RoundButton(
          title: LocaleKey.completeEx.tr,
          onPressed: () => Navigator.pop(Get.context!),
        ),
      ),
    );
  }

  /// Build chip widget cho tags
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color? textColor,
    Key? key,
  }) {
    return Container(
      key: key,
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
