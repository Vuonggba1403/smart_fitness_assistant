import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';

/// Bottom sheet hiển thị chi tiết exercise
///
/// Hiển thị:
/// - Video/Image thumbnail với play button
/// - Thông tin thiết bị (Có/Không có)
/// - Khu vực tập trung (muscle group)
/// - Muscle diagram (front/back view)
/// - Hướng dẫn thực hiện (description)
class ExerciseDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailBottomSheet({super.key, required this.exercise});

  /// Hiển thị bottom sheet
  static void show(BuildContext context, Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailBottomSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
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
            // Header
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
                    exercise['title']?.toString() ?? 'Exercise',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video/Image thumbnail với play button
                    _buildVideoThumbnail(media, cardColor, textColor),

                    const SizedBox(height: 24),

                    // Cơ section (Có/Không có thiết bị)
                    _buildEquipmentSection(textColor),

                    const SizedBox(height: 24),

                    // Khu vực tập trung section
                    _buildMuscleGroupSection(textColor),

                    const SizedBox(height: 24),

                    // Muscle diagram
                    _buildMuscleDiagram(media, cardColor),

                    const SizedBox(height: 24),

                    // Hướng dẫn thực hiện
                    _buildInstructions(textColor),

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
                  title: "Hoàn tất",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build video thumbnail với play button overlay
  Widget _buildVideoThumbnail(Size media, Color cardColor, Color? textColor) {
    return Container(
      height: media.height * 0.25,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: TColor.gray.withOpacity(0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: exercise['img_url']?.toString() ?? '',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(color: TColor.primaryColor1),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.fitness_center, size: 60, color: TColor.gray),
            ),
          ),

          // Play button overlay
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  /// Build equipment section (Có/Không có thiết bị)
  Widget _buildEquipmentSection(Color? textColor) {
    final hasEquipment = exercise['device']?.toString().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thiết bị',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip(
              label: hasEquipment
                  ? exercise['device']?.toString() ?? 'Có'
                  : 'Không có',
              isSelected: hasEquipment,
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }

  /// Build muscle group section
  Widget _buildMuscleGroupSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khu vực tập trung',
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
          children: [
            _buildChip(
              label: exercise['muscle_group']?.toString() ?? 'Toàn thân',
              isSelected: true,
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }

  /// Build muscle diagram (front/back view)
  Widget _buildMuscleDiagram(Size media, Color cardColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Front view
        _buildMusclePlaceholder(media, cardColor, 'Front'),

        // Back view
        _buildMusclePlaceholder(media, cardColor, 'Back'),
      ],
    );
  }

  /// Build muscle diagram placeholder
  Widget _buildMusclePlaceholder(Size media, Color cardColor, String label) {
    return Column(
      children: [
        Container(
          height: media.height * 0.25,
          width: media.width * 0.35,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: TColor.gray.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.accessibility_new,
            size: 80,
            color: TColor.gray.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 12)),
      ],
    );
  }

  /// Build instructions section
  Widget _buildInstructions(Color? textColor) {
    final description = exercise['des']?.toString() ?? '';

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cách thực hiện',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: textColor?.withOpacity(0.8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Build chip widget
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color? textColor,
  }) {
    return Container(
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
