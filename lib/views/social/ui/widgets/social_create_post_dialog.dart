import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'dart:io';

import '../../../../locale/locale_key.dart';

/// ✅ Widget: Create Post Bottom Sheet Dialog
class SocialCreatePostDialog extends StatelessWidget {
  final File? selectedImage;
  final TextEditingController captionController;
  final List<ExerciseCategory>? categories;
  final ExerciseCategory? selectedCategory;
  final VoidCallback onImagePickerTap;
  final VoidCallback? onImageRemove;
  final Function(ExerciseCategory?) onCategoryChanged;
  final VoidCallback onPostPressed;

  const SocialCreatePostDialog({
    super.key,
    required this.selectedImage,
    required this.captionController,
    required this.categories,
    required this.selectedCategory,
    required this.onImagePickerTap,
    this.onImageRemove,
    required this.onCategoryChanged,
    required this.onPostPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cardColor,
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
                LocaleKey.createPost.tr,
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
                      onTap: onImagePickerTap,
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
                        child: selectedImage == null
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
                                    LocaleKey.choiceImg.tr,
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
                      LocaleKey.tagWork.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
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
                          color: TColor.primaryColor2,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: cardColor,
                      ),
                      child: categories == null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Đang tải...',
                                style: TextStyle(color: TColor.gray),
                              ),
                            )
                          : DropdownButton<ExerciseCategory>(
                              isExpanded: true,
                              hint: selectedCategory == null
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: textColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          LocaleKey.chooseWork.tr,
                                          style: TextStyle(
                                            color: textColor,
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
                                          color: textColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            selectedCategory!.titleEx ?? 'N/A',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                              value: selectedCategory,
                              underline: const SizedBox.shrink(),
                              items: categories!.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.titleEx ?? 'N/A',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: onCategoryChanged,
                              dropdownColor: textColor,
                              borderRadius: BorderRadius.circular(10),

                              icon: Icon(
                                Icons.expand_more,
                                color: selectedCategory != null
                                    ? TColor.primaryColor1
                                    : TColor.gray,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Preview ảnh đã chọn
                    if (selectedImage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKey.submitPic.tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  selectedImage!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: onImageRemove,
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
                              onPressed: onImagePickerTap,
                              icon: Icon(Icons.edit, size: 18),
                              label: Text(LocaleKey.changePic.tr),
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

                    // ✅ Caption Input (removed emoji picker)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKey.caption.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
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
                            controller: captionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: LocaleKey.writeCap.tr,
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
                        onPressed: onPostPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          LocaleKey.postNew.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
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
