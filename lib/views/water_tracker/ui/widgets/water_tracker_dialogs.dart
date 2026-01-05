import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// ✨ Gộp 3 dialogs: Goal, Reminder, Congratulations
class WaterTrackerDialogs {
  /// Dialog để cập nhật daily goal
  static Future<int?> showGoalDialog(BuildContext context, int currentGoal) {
    int tempGoal = currentGoal;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            title: Text(LocaleKey.dailyGoal.tr),
            backgroundColor: theme.dialogBackgroundColor,
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
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                    Text(
                      '5000ml',
                      style: TextStyle(fontSize: 12, color: textColor),
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, tempGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                child: Text(
                  LocaleKey.buttonSave.tr,
                  style: TextStyle(color: TColor.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Dialog để cập nhật reminder settings
  static Future<WaterGoalSettings?> showReminderDialog(
    BuildContext context,
    WaterGoalSettings currentSettings,
  ) {
    WaterGoalSettings tempSettings = currentSettings;
    final theme = Theme.of(context);

    return showDialog<WaterGoalSettings>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            backgroundColor: theme.dialogBackgroundColor,
            title: Center(child: Text(LocaleKey.reminderWater.tr)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✨ Info box cảnh báo
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '💡 Khuyến nghị: Không nên uống nước sau 11h đêm để tránh trữ nước',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _IntervalTile(
                    currentInterval: tempSettings.reminderIntervalMinutes,
                    onIntervalChanged: (interval) {
                      setDialogState(() {
                        tempSettings = tempSettings.copyWith(
                          reminderIntervalMinutes: interval,
                        );
                      });
                    },
                  ),
                  _TimeTile(
                    title: LocaleKey.reminderWater.tr,
                    time: tempSettings.reminderStartTime,
                    onTimeChanged: (time) {
                      setDialogState(() {
                        tempSettings = tempSettings.copyWith(
                          reminderStartTime: time,
                        );
                      });
                    },
                  ),
                  _TimeTile(
                    title: LocaleKey.endWater.tr,
                    time: tempSettings.reminderEndTime,
                    isEndTime: true, // ✨ Đánh dấu là end time
                    onTimeChanged: (time) {
                      // ✨ Kiểm tra nếu chọn sau 23:00 (11 PM)
                      if (time.hour >= 23) {
                        // Hiện cảnh báo
                        AppSnackBar.error(
                          context,
                          '⚠️ Không nên uống nước sau 11h đêm!\n'
                          '💤 Hãy để cơ thể nghỉ ngơi, uống nước ban đêm sẽ bị trữ nước.',
                        );

                        // Tự động điều chỉnh về 23:00
                        final adjustedTime = const TimeOfDay(
                          hour: 23,
                          minute: 0,
                        );
                        setDialogState(() {
                          tempSettings = tempSettings.copyWith(
                            reminderEndTime: adjustedTime,
                          );
                        });
                      } else {
                        setDialogState(() {
                          tempSettings = tempSettings.copyWith(
                            reminderEndTime: time,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  LocaleKey.buttonNo.tr,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedSettings = tempSettings.copyWith(
                    reminderEnabled: true,
                  );
                  Navigator.pop(dialogContext, updatedSettings);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                child: Text(
                  LocaleKey.buttonYes.tr,
                  style: TextStyle(color: TColor.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Dialog chúc mừng khi đạt goal
  static Future<void> showCongratulationsDialog(
    BuildContext context,
    int totalMl,
    int goalMl,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TColor.primaryColor1.withOpacity(0.3),
                      TColor.primaryColor2.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                LocaleKey.titleDialogWater.tr,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                LocaleKey.contentDialogWater.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColor.primaryColor1.withOpacity(0.1),
                      TColor.primaryColor2.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${totalMl}ml / ${goalMl}ml',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      LocaleKey.textDialog.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    LocaleKey.buttonCon.tr,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== Private Helper Widgets ==========

class _IntervalTile extends StatelessWidget {
  final int currentInterval;
  final ValueChanged<int> onIntervalChanged;

  const _IntervalTile({
    required this.currentInterval,
    required this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(LocaleKey.nhac.tr),
      subtitle: Text('$currentInterval ${LocaleKey.mins.tr}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final intervals = [30, 60, 90, 120, 180];
        final selected = await showDialog<int>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(LocaleKey.khoangtime.tr),
            children: intervals.map((interval) {
              return SimpleDialogOption(
                child: Text('$interval ${LocaleKey.mins.tr}'),
                onPressed: () => Navigator.pop(ctx, interval),
              );
            }).toList(),
          ),
        );

        if (selected != null) {
          onIntervalChanged(selected);
        }
      },
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String title;
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool isEndTime; // ✨ Flag để biết có phải end time không

  const _TimeTile({
    required this.title,
    required this.time,
    required this.onTimeChanged,
    this.isEndTime = false, // Default là false
  });

  @override
  Widget build(BuildContext context) {
    final displayTime = time ?? const TimeOfDay(hour: 8, minute: 0);

    return ListTile(
      title: Text(title),
      subtitle: Row(
        children: [
          Text(
            '${displayTime.hour.toString().padLeft(2, '0')}:'
            '${displayTime.minute.toString().padLeft(2, '0')}',
          ),
          // ✨ Hiển thị warning icon nếu là end time và > 23:00
          if (isEndTime && displayTime.hour >= 23)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 18,
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: displayTime,
        );

        if (selectedTime != null) {
          onTimeChanged(selectedTime);
        }
      },
    );
  }
}
