import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/functions/colo_extension.dart';
import 'common/exercises_row.dart';

class ExercisesSetSection extends StatelessWidget {
  final Map sObj;
  final Function(Map obj) onPressed;
  const ExercisesSetSection({
    super.key,
    required this.sObj,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var exercisesArr = sObj["set"] as List? ?? [];
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sObj["name"].toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: exercisesArr.length,
          itemBuilder: (context, index) {
            var eObj = exercisesArr[index] as Map? ?? {};
            return ExercisesRow(
              eObj: eObj,
              onPressed: () {
                onPressed(eObj);
              },
            );
          },
        ),
      ],
    );
  }
}
