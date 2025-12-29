import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

class WorkoutTimePicker {
  /// Hiển thị dialog chọn giờ cho workout
  static Future<DateTime?> show(BuildContext context) async {
    final now = DateTime.now();
    TimeOfDay? pickedTime;
    DateTime? pickedDate;

    // Bước 1: Chọn ngày
    pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primaryColor1,
              onPrimary: Colors.white,
              onSurface: TColor.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return null;

    // Bước 2: Chọn giờ
    if (context.mounted) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: TColor.primaryColor1,
                onPrimary: Colors.white,
                onSurface: TColor.black,
              ),
            ),
            child: child!,
          );
        },
      );
    }

    if (pickedTime == null) return null;

    // Kết hợp ngày và giờ
    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    return scheduledDateTime;
  }
}
