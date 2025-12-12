import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'dart:io';

/// ✅ Widget: Create Post Bottom Sheet Dialog
class SocialCreatePostDialog extends StatefulWidget {
  final File? selectedImage;
  final TextEditingController captionController;
  final bool showEmojiPicker;
  final List<ExerciseCategory>? categories;
  final ExerciseCategory? selectedCategory;
  final VoidCallback onImagePickerTap;
  final Function(ExerciseCategory?) onCategoryChanged;
  final VoidCallback onEmojiToggle;
  final VoidCallback onPostPressed;
  final Function(bool) onShowEmojiPickerChanged;

  const SocialCreatePostDialog({
    super.key,
    required this.selectedImage,
    required this.captionController,
    required this.showEmojiPicker,
    required this.categories,
    required this.selectedCategory,
    required this.onImagePickerTap,
    required this.onCategoryChanged,
    required this.onEmojiToggle,
    required this.onPostPressed,
    required this.onShowEmojiPickerChanged,
  });

  @override
  State<SocialCreatePostDialog> createState() =>
      _SocialCreatePostDialogState();
}

class _SocialCreatePostDialogState extends State<SocialCreatePostDialog> {
  late ExerciseCategory? _localSelectedCategory;

  @override
  void initState() {
    super.initState();
    _localSelectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: TColor.gray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tạo bài đăng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Image Picker
                    InkWell(
                      onTap: widget.onImagePickerTap,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: TColor.gray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: TColor.primaryColor1.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: widget.selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                        color: TColor.primaryColor1,
                                      ),
                                      const SizedBox(width: 20),
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 40,
                                        color: TColor.primaryColor1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Chụp ảnh hoặc chọn từ thư viện',
                                    style: TextStyle(
                                      color: TColor.primaryColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      widget.selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: TColor.primaryColor1,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: TColor.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Category Tag Section - FIX: Dùng local state
                    Text(
                      'Gắn thẻ bài tập (tuỳ chọn)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _localSelectedCategory != null
                              ? TColor.primaryColor1
                              : TColor.gray.withOpacity(0.3),
                          width: _localSelectedCategory != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: _localSelectedCategory != null
                            ? TColor.primaryColor1.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: widget.categories == null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Đang tải...',
                                style: TextStyle(color: TColor.gray),
                              ),
                            )
                          : DropdownButton<ExerciseCategory>(
                              isExpanded: true,
                              // ✅ FIX: Dùng conditional hint với local state
                              hint: _localSelectedCategory == null
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: TColor.gray,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Chọn bài tập...',
                                          style: TextStyle(
                                            color: TColor.gray,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: TColor.primaryColor1,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _localSelectedCategory!.titleEx ??
                                                'N/A',
                                            style: TextStyle(
                                              color: TColor.primaryColor1,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                              value: _localSelectedCategory,
                              underline: const SizedBox.shrink(),
                              items: widget.categories!.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.titleEx ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (category) {
                                // ✅ Update local state
                                setState(() {
                                  _localSelectedCategory = category;
                                });
                                // ✅ Notify parent
                                widget.onCategoryChanged(category);
                              },
                              dropdownColor:
                                  theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              icon: Icon(
                                Icons.expand_more,
                                color: _localSelectedCategory != null
                                    ? TColor.primaryColor1
                                    : TColor.gray,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Caption Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Caption',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TColor.gray.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: TColor.gray.withOpacity(0.05),
                          ),
                          child: TextField(
                            controller: widget.captionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Viết caption...*',
                              hintStyle: TextStyle(
                                color: TColor.gray.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ✅ Post Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.onPostPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Đăng bài',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
