import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_calendar_agenda.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  const WorkoutScheduleView({super.key});

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  late DateTime _selectedDateAppBBar;
  List<ScheduledWorkout> _scheduledWorkouts = []; // ✅ THÊM
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _loadSchedules(); // ✅ Load từ DB
  }

  // ✅ Load schedules từ Supabase
  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final startOfDay = DateTime(
        _selectedDateAppBBar.year,
        _selectedDateAppBBar.month,
        _selectedDateAppBBar.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('scheduled_workouts')
          .select()
          .eq('for_user', userId)
          .gte('scheduled_time', startOfDay.toIso8601String())
          .lt('scheduled_time', endOfDay.toIso8601String())
          .order('scheduled_time');

      _scheduledWorkouts = response
          .map((json) => ScheduledWorkout.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error loading schedules: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ Delete schedule
  Future<void> _deleteSchedule(ScheduledWorkout schedule) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .delete()
          .eq('id', schedule.id!);
      await _notificationService.cancelNotification(schedule.id.hashCode);
      _loadSchedules();
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  // ✅ Mark schedule as completed
  Future<void> _markAsCompleted(ScheduledWorkout schedule) async {
    try {
      await _supabase
          .from('scheduled_workouts')
          .update({'is_completed': true})
          .eq('id', schedule.id!);

      await _notificationService.cancelNotification(schedule.id.hashCode);

      _loadSchedules(); // ✅ Reload local

      if (mounted) {
        AppSnackBar.success(context, '✅ Đã đánh dấu hoàn thành');
      }
    } catch (e) {
      print('❌ Error marking completed: $e');
    }
  }

  // ✅ THÊM method getTime
  String getTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '12:${mins.toString().padLeft(2, '0')} AM';
    } else if (hours < 12) {
      return '$hours:${mins.toString().padLeft(2, '0')} AM';
    } else if (hours == 12) {
      return '12:${mins.toString().padLeft(2, '0')} PM';
    } else {
      return '${hours - 12}:${mins.toString().padLeft(2, '0')} PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.dailyWorkoutSchedule.tr),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Use CustomCalendarAgenda
          CustomCalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            selectedDate: _selectedDateAppBBar,
            textColor: textColor,
            onDateSelected: (date) {
              setState(() {
                _selectedDateAppBBar = date;
              });
              _loadSchedules();
            },
          ),

          // ✅ Timeline với tags
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var availWidth = (media.width * 1.2) - (80 + 40);

                    // ✅ Lọc schedules theo giờ
                    var slotsForHour = _scheduledWorkouts.where((s) {
                      return s.scheduledTime.hour == index;
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Giờ
                          SizedBox(
                            width: 80,
                            child: Text(
                              getTime(index * 60),
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                          ),

                          // ✅ Tags cho schedules
                          if (slotsForHour.isNotEmpty)
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: slotsForHour.map((schedule) {
                                  var min = schedule.scheduledTime.minute;
                                  var pos = (min / 60) * 2 - 1;

                                  return Align(
                                    alignment: Alignment(pos, 0),
                                    child: _buildScheduleTag(
                                      schedule,
                                      availWidth,
                                      textColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      Divider(color: TColor.gray.withOpacity(0.2), height: 1),
                  itemCount: 24,
                ),
              ),
            ),
          ),
        ],
      ),

      // ✅ FAB thêm lịch - Listen result
      floatingActionButton: InkWell(
        onTap: () async {
          final result = await navigateTo(
            context,
            AddScheduleView(date: _selectedDateAppBBar),
          );

          // ✅ Refresh nếu có result = true
          if (result == true && mounted) {
            await _loadSchedules();

            // ✅ Debug: Kiểm tra lại DB
            print('🔄 Reloading schedules after add...');
            final userId = _supabase.auth.currentUser?.id;
            final count = await _supabase
                .from('scheduled_workouts')
                .select('id')
                .eq('for_user', userId!)
                .count();
            print('📊 Total schedules in DB: $count');
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.primaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.add, size: 20, color: TColor.white),
        ),
      ),
    );
  }

  // ✅ Build schedule tag (giống ảnh gốc)
  Widget _buildScheduleTag(
    ScheduledWorkout schedule,
    double availWidth,
    Color? textColor,
  ) {
    final timeStr = DateFormat('h:mm a').format(schedule.scheduledTime);

    return InkWell(
      onTap: () => _showScheduleOptions(schedule),
      child: Container(
        height: 35,
        width: availWidth * 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.secondaryG),
          borderRadius: BorderRadius.circular(17.5),
        ),
        child: Text(
          "${schedule.categoryName}, $timeStr",
          maxLines: 1,
          style: TextStyle(color: TColor.white, fontSize: 12),
        ),
      ),
    );
  }

  // ✅ Dialog options (xóa, mark done)
  void _showScheduleOptions(ScheduledWorkout schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                schedule.categoryName,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                DateFormat('h:mm a').format(schedule.scheduledTime),
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Mark Done button
              RoundButton(
                title: "Hoàn thành",
                onPressed: () {
                  Navigator.pop(context);
                  _markAsCompleted(schedule);
                },
              ),

              const SizedBox(height: 10),

              // Delete button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSchedule(schedule);
                },
                child: Text('Xóa lịch', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
