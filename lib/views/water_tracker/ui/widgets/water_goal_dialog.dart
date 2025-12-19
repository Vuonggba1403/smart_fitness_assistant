import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class WaterGoalDialog {
  static Future<int?> show(BuildContext context, int currentGoal) {
    int tempGoal = currentGoal;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            title: const Text('Mục tiêu hàng ngày'),
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
                      style: TextStyle(fontSize: 12, color: TColor.gray),
                    ),
                    Text(
                      '5000ml',
                      style: TextStyle(fontSize: 12, color: TColor.gray),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, tempGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }
}
