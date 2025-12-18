import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/water_tracker/logic/cubit/water_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/water_congratulations_dialog.dart'; // ✅ THÊM
import 'dart:math' as math;

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaterTrackerCubit(),
      child: const _WaterTrackerContent(),
    );
  }
}

class _WaterTrackerContent extends StatefulWidget {
  const _WaterTrackerContent();

  @override
  State<_WaterTrackerContent> createState() => _WaterTrackerContentState();
}

class _WaterTrackerContentState extends State<_WaterTrackerContent> {
  int _selectedAmount = 200;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ Dialog chỉnh goal - FIX setState
  void _showGoalDialog(int currentGoal) {
    int tempGoal = currentGoal;
    final widgetContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            title: const Text('Mục tiêu hàng ngày'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tempGoal}ml', // ✅ Hiển thị giá trị đang chọn
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
                // ✅ Range text
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
                onPressed: () async {
                  // ✅ Update goal
                  await widgetContext.read<WaterTrackerCubit>().updateGoal(
                    tempGoal,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  // ✅ Show success message
                  if (widgetContext.mounted) {
                    AppSnackBar.success(
                      widgetContext,
                      'Đã cập nhật mục tiêu: ${tempGoal}ml',
                    );
                  }
                },
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

  // ✅ Dialog cài đặt reminder - BỎ phần tắt/bật
  void _showReminderDialog(WaterGoalSettings settings) {
    WaterGoalSettings tempSettings = settings;
    final widgetContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return AlertDialog(
            title: const Text('Nhắc nhở uống nước'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ❌ XÓA: Enable/Disable switch - Luôn bật

                  // Interval
                  ListTile(
                    title: const Text('Nhắc mỗi'),
                    subtitle: Text(
                      '${tempSettings.reminderIntervalMinutes} phút',
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {
                      final intervals = [30, 60, 90, 120, 180];
                      final selected = await showDialog<int>(
                        context: builderContext,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Chọn khoảng thời gian'),
                          children: intervals.map((interval) {
                            return SimpleDialogOption(
                              child: Text('$interval phút'),
                              onPressed: () => Navigator.pop(ctx, interval),
                            );
                          }).toList(),
                        ),
                      );

                      if (selected != null) {
                        setDialogState(() {
                          tempSettings = tempSettings.copyWith(
                            reminderIntervalMinutes: selected,
                          );
                        });
                      }
                    },
                  ),

                  // Start time
                  ListTile(
                    title: const Text('Bắt đầu từ'),
                    subtitle: Text(
                      tempSettings.reminderStartTime == null
                          ? '08:00'
                          : '${tempSettings.reminderStartTime!.hour.toString().padLeft(2, '0')}:${tempSettings.reminderStartTime!.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: builderContext,
                        initialTime:
                            tempSettings.reminderStartTime ??
                            const TimeOfDay(hour: 8, minute: 0),
                      );

                      if (time != null) {
                        setDialogState(() {
                          tempSettings = tempSettings.copyWith(
                            reminderStartTime: time,
                          );
                        });
                      }
                    },
                  ),

                  // End time
                  ListTile(
                    title: const Text('Kết thúc lúc'),
                    subtitle: Text(
                      tempSettings.reminderEndTime == null
                          ? '22:00'
                          : '${tempSettings.reminderEndTime!.hour.toString().padLeft(2, '0')}:${tempSettings.reminderEndTime!.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: builderContext,
                        initialTime:
                            tempSettings.reminderEndTime ??
                            const TimeOfDay(hour: 22, minute: 0),
                      );

                      if (time != null) {
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
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ✅ Luôn set reminderEnabled = true
                  final updatedSettings = tempSettings.copyWith(
                    reminderEnabled: true, // ✅ Force bật
                  );

                  await widgetContext
                      .read<WaterTrackerCubit>()
                      .updateReminderSettings(updatedSettings);

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  // ✅ Show success message
                  if (widgetContext.mounted) {
                    AppSnackBar.success(
                      widgetContext,
                      'Đã cập nhật nhắc nhở: ${updatedSettings.reminderIntervalMinutes} phút',
                    );
                  }
                },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.primaryColor1,
      // ✅ THÊM: BlocListener để listen WaterGoalAchieved
      body: BlocListener<WaterTrackerCubit, WaterTrackerState>(
        listener: (context, state) {
          // ✅ Show congratulations khi đạt goal
          if (state is WaterGoalAchieved) {
            WaterCongratulationsDialog.show(
              context,
              state.totalMl,
              state.goalMl,
            );
          }
        },
        child: BlocBuilder<WaterTrackerCubit, WaterTrackerState>(
          builder: (context, state) {
            if (state is WaterTrackerLoading) {
              return const Center(child: CustomCircleProgIndicator());
            }

            if (state is WaterTrackerError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // ✅ Handle cả WaterTrackerLoaded và WaterGoalAchieved
            final WaterTrackerLoaded loadedState;
            if (state is WaterTrackerLoaded) {
              loadedState = state;
            } else if (state is WaterGoalAchieved) {
              // ✅ Temporary: Hiển thị loading trong khi chờ reload
              return const Center(child: CustomCircleProgIndicator());
            } else {
              return const SizedBox.shrink();
            }

            return SafeArea(
              child: Column(
                children: [
                  // Header với settings icon
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: TColor.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Ghi nước\nmột chạm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: TColor.white),
                          onPressed: () => _showGoalDialog(loadedState.goalMl),
                        ),
                      ],
                    ),
                  ),

                  // Circular Progress
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: media.width * 0.7,
                            height: media.width * 0.7,
                            child: CustomPaint(
                              painter: _WaterProgressPainter(
                                progress: loadedState.progress,
                              ),
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Daily goal',
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () =>
                                    _showGoalDialog(loadedState.goalMl),
                                child: Text(
                                  '${loadedState.totalMl}/${loadedState.goalMl}ml',
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_drink,
                                    color: TColor.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                    color: TColor.white,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Water Amount Selector
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chevron_left, color: TColor.white),
                            const SizedBox(width: 20),
                            Text(
                              '${_selectedAmount}ml',
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Icon(Icons.chevron_right, color: TColor.white),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [100, 200, 300, 400].map((amount) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAmount = amount;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedAmount == amount
                                      ? TColor.white
                                      : TColor.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${amount}ml',
                                  style: TextStyle(
                                    color: _selectedAmount == amount
                                        ? TColor.primaryColor1
                                        : TColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Next Reminder
                  InkWell(
                    onTap: () => _showReminderDialog(loadedState.settings),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _getNextReminderText(loadedState.settings),
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: TColor.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),

      // FAB Add Water
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<WaterTrackerCubit>().addWaterIntake(_selectedAmount);
        },
        backgroundColor: TColor.white,
        child: Icon(Icons.add, color: TColor.primaryColor1, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ✅ Tính next reminder time
  String _getNextReminderText(WaterGoalSettings settings) {
    final now = DateTime.now();
    final startTime =
        settings.reminderStartTime ?? const TimeOfDay(hour: 8, minute: 0);

    final nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    if (nextReminder.isAfter(now)) {
      return '${nextReminder.hour.toString().padLeft(2, '0')}:${nextReminder.minute.toString().padLeft(2, '0')}';
    } else {
      final tomorrow = nextReminder.add(const Duration(days: 1));
      return 'Tomorrow ${tomorrow.hour.toString().padLeft(2, '0')}:${tomorrow.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Custom Painter for Water Progress Circle
class _WaterProgressPainter extends CustomPainter {
  final double progress;

  _WaterProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = TColor.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = TColor.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_WaterProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
