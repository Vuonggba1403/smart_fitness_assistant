import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CustomDropButtonUnder extends StatelessWidget {
  const CustomDropButtonUnder({
    super.key,
    required this.items,
    this.imagePaths,
    required this.hint,
    this.selectedValue,
    this.onChanged,
  });

  final List<String> items;
  final List<String>? imagePaths;
  final String hint;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        value: selectedValue,
        isExpanded: true,
        iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
        dropdownStyleData: DropdownStyleData(
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.1)),
            ],
          ),
        ),
        buttonStyleData: ButtonStyleData(
          height: 35,
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: TColor.secondaryG),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 10),
        ),

        /// ✳️ Phần hiển thị trên button chính (không có icon check)
        selectedItemBuilder: (context) {
          return items.map((item) {
            final index = items.indexOf(item);
            final imagePath = (imagePaths != null && index < imagePaths!.length)
                ? imagePaths![index]
                : null;

            return Row(
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                if (imagePath != null) const SizedBox(width: 8),
                Text(item, style: theme.textTheme.bodyMedium),
              ],
            );
          }).toList();
        },

        /// ✳️ Các item trong dropdown menu (có icon check nếu đang được chọn)
        items: List.generate(items.length, (index) {
          final item = items[index];
          final imagePath = (imagePaths != null && index < imagePaths!.length)
              ? imagePaths![index]
              : null;

          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    if (imagePath != null) const SizedBox(width: 8),
                    Text(item, style: theme.textTheme.bodyMedium),
                  ],
                ),
                if (selectedValue == item)
                  Icon(Icons.check, color: textColor, size: 18),
              ],
            ),
          );
        }),
        onChanged: onChanged,

        /// Hint mặc định (chưa chọn gì)
        hint: Row(
          children: [
            if (imagePaths != null && imagePaths!.isNotEmpty) ...[
              Image.asset(
                imagePaths!.first,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
            ],
            Text(hint, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
