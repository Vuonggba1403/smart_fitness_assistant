import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class WorkoutProgressHeader extends StatelessWidget {
  final VoidCallback? onDropdownChanged;

  const WorkoutProgressHeader({super.key, this.onDropdownChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color; // Màu text chính
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Workout Progress",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.primaryG),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              items: ["Weekly", "Monthly"]
                  .map(
                    (name) => DropdownMenuItem(
                      value: name,
                      child: Text(
                        name,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => onDropdownChanged?.call(),
              icon: Icon(Icons.expand_more, color: textColor),
              hint: Text(
                "Weekly",
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
