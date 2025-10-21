import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class WorkoutProgressHeader extends StatelessWidget {
  final VoidCallback? onDropdownChanged;

  const WorkoutProgressHeader({super.key, this.onDropdownChanged});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Workout Progress",
          style: TextStyle(
            color: TColor.black,
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
                        style: TextStyle(color: TColor.gray, fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => onDropdownChanged?.call(),
              icon: Icon(Icons.expand_more, color: TColor.white),
              hint: Text(
                "Weekly",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
