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

    return DropdownButtonHideUnderline(
      // THÊM DÒNG NÀY
      child: DropdownButton2<String>(
        value: selectedValue,
        isExpanded: true,
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down, size: 22),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 100,
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
          width: 100,
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
        items: List.generate(items.length, (index) {
          final imagePath = (imagePaths != null && index < imagePaths!.length)
              ? imagePaths![index]
              : null;
          return DropdownMenuItem<String>(
            value: items[index],
            child: Row(
              children: [
                if (imagePath != null && imagePath.isNotEmpty) ...[
                  Image.asset(
                    imagePath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(items[index], style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }),
        onChanged: onChanged,
      ),
    );
  }
}
