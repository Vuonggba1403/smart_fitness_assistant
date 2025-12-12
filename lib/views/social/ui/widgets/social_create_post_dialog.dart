import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  final VoidCallback? onImageRemove; // ✅ THÊM
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
    this.onImageRemove, // ✅ THÊM
    required this.onCategoryChanged,
    required this.onEmojiToggle,
    required this.onPostPressed,
    required this.onShowEmojiPickerChanged,
  });

  @override
  State<SocialCreatePostDialog> createState() => _SocialCreatePostDialogState();
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
                        height: 150,
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
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: TColor.primaryColor1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chọn ảnh từ thư viện',
                                    style: TextStyle(
                                      color: TColor.primaryColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Icon(
                                Icons.check_circle,
                                size: 50,
                                color: Colors.green,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Category Tag Section
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
                                setState(() {
                                  _localSelectedCategory = category;
                                });
                                widget.onCategoryChanged(category);
                              },
                              dropdownColor: theme.scaffoldBackgroundColor,
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

                    // ✅ THÊM: Preview ảnh đã chọn
                    if (widget.selectedImage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ảnh đã chọn',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.selectedImage!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: widget.onImageRemove,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: widget.onImagePickerTap,
                              icon: Icon(Icons.edit, size: 18),
                              label: const Text('Thay đổi ảnh'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: TColor.primaryColor1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

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
                          child: Row(
                            children: [
                              Expanded(
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
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.sentiment_satisfied_outlined,
                                    size: 28,
                                    color: Colors.orange,
                                  ),
                                  onPressed: widget.onEmojiToggle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ Emoji Picker
                        if (widget.showEmojiPicker)
                          SizedBox(
                            height: 256,
                            child: EmojiPicker(
                              onEmojiSelected:
                                  (Category? category, Emoji emoji) {
                                    widget.captionController.text +=
                                        emoji.emoji;
                                  },
                              onBackspacePressed: () {
                                if (widget.captionController.text.isNotEmpty) {
                                  widget.captionController.text = widget
                                      .captionController
                                      .text
                                      .substring(
                                        0,
                                        widget.captionController.text.length -
                                            1,
                                      );
                                }
                              },
                              textEditingController: widget.captionController,
                              config: Config(
                                height: 256,
                                checkPlatformCompatibility: true,
                                emojiViewConfig: EmojiViewConfig(
                                  emojiSizeMax:
                                      28 *
                                      (foundation.defaultTargetPlatform ==
                                              TargetPlatform.iOS
                                          ? 1.20
                                          : 1.0),
                                ),
                                viewOrderConfig: const ViewOrderConfig(
                                  top: EmojiPickerItem.categoryBar,
                                  middle: EmojiPickerItem.emojiView,
                                  bottom: EmojiPickerItem.searchBar,
                                ),
                                skinToneConfig: const SkinToneConfig(),
                                categoryViewConfig: const CategoryViewConfig(),
                                bottomActionBarConfig:
                                    const BottomActionBarConfig(),
                                searchViewConfig: const SearchViewConfig(),
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
