import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/functions/colo_extension.dart';

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

/// Single Exercise Row Widget
class ExercisesRow extends StatelessWidget {
  final Map eObj;
  final VoidCallback onPressed;
  const ExercisesRow({super.key, required this.eObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              eObj["image"].toString(),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eObj["title"].toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  eObj["value"].toString(),
                  style: TextStyle(
                    color: textColor?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPressed,
            icon: Image.asset(
              "assets/img/next_go.png",
              width: 20,
              height: 20,
              color: textColor,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
