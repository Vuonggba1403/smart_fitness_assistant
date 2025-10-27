import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CustomDropButtonUnder extends StatelessWidget {
  const CustomDropButtonUnder({
    super.key,
    required this.items,
    required this.hint,
    this.onChanged,
  });

  final List<String> items;
  final String hint;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: items
            .map(
              (name) => DropdownMenuItem(
                value: name,
                child: Text(
                  name,
                  style: TextStyle(
                    color: textColor?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: Icon(Icons.expand_more, color: TColor.white),
        hint: Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(color: TColor.white, fontSize: 12),
        ),
      ),
    );
  }
}
