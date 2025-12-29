import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

import '../../../../core/widgets/custom_showdialog.dart';
import '../../../../locale/locale_key.dart';

class WaterGoalDialog {
  static Future<int?> show(BuildContext context, int currentGoal) {
    int tempGoal = currentGoal;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            title: Text(LocaleKey.dailyGoal.tr),
            backgroundColor: Colors.grey.shade800,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tempGoal}ml',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TColor.primaryColor1,
                  ),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: tempGoal.toDouble(),
                  min: 500,
                  max: 5000,
                  divisions: 45,
                  label: '${tempGoal}ml',
                  activeColor: TColor.primaryColor1,
                  onChanged: (value) {
                    setDialogState(() {
                      tempGoal = value.round();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '500ml',
                      style: TextStyle(fontSize: 12, color: TColor.white),
                    ),
                    Text(
                      '5000ml',
                      style: TextStyle(fontSize: 12, color: TColor.white),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  LocaleKey.buttonNo.tr,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, tempGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                child: Text(
                  LocaleKey.buttonSave.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
