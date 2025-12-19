import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

class WaterReminderDialog {
  static Future<WaterGoalSettings?> show(
    BuildContext context,
    WaterGoalSettings currentSettings,
  ) {
    WaterGoalSettings tempSettings = currentSettings;

    return showDialog<WaterGoalSettings>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            // shape: const RoundedRectangleBorder(),
            backgroundColor: Colors.grey.shade800,
            title:  Center(child: Text(LocaleKey.reminderWater.tr)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    onTimeChanged: (time) {
                      setDialogState(() {
                        tempSettings = tempSettings.copyWith(
                          reminderEndTime: time,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child:  Text(LocaleKey.buttonNo.tr,style: TextStyle(color: Colors.red,),),
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
                child: Text(LocaleKey.buttonYes.tr,style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
            title:  Text(LocaleKey.khoangtime.tr),
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

  const _TimeTile({
    required this.title,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayTime = time ?? const TimeOfDay(hour: 8, minute: 0);

    return ListTile(
      title: Text(title),
      subtitle: Text(
        '${displayTime.hour.toString().padLeft(2, '0')}:'
        '${displayTime.minute.toString().padLeft(2, '0')}',
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
