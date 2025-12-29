import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_calendar_agenda.dart';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:smart_fitness_assistant/views/schedule_management/logic/cubit/schedule_cubit.dart';
import 'package:smart_fitness_assistant/views/schedule_management/ui/widgets/add_schedule_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/round_button.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _supabase = Supabase.instance.client;
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDate;
  final Map<String, String> _categoryNamesCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSchedulesForSelectedDate();
  }

  void _loadSchedulesForSelectedDate() {
    context.read<ScheduleCubit>().loadSchedulesByDate(_selectedDate);
  }

  // ✅ ADD: Method để lấy category name (có cache)
  Future<String> _getCategoryName(String categoryId) async {
    if (_categoryNamesCache.containsKey(categoryId)) {
      return _categoryNamesCache[categoryId]!;
    }

    try {
      final response = await _supabase
          .from('exercise_categories')
          .select('title_ex')
          .eq('id', categoryId)
          .single();

      final categoryName = response['title_ex'] ?? 'Workout';
      _categoryNamesCache[categoryId] = categoryName;
      return categoryName;
    } catch (e) {
      print('⚠️ Error loading category name: $e');
      return 'Workout';
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final success = await context.read<ScheduleCubit>().deleteSchedule(
      scheduleId,
    );

    if (success && mounted) {
      AppSnackBar.success(context, LocaleKey.deletedWorkout.tr);

      // ✅ FIX: Reload data ngay sau khi xóa
      _loadSchedulesForSelectedDate();
    }
  }

  Future<void> _markAsCompleted(String scheduleId) async {
    final success = await context.read<ScheduleCubit>().markScheduleAsCompleted(
      scheduleId,
    );

    if (success && mounted) {
      AppSnackBar.success(context, '✅ Đã đánh dấu hoàn thành');

      // ✅ FIX: Reload data ngay sau khi complete
      _loadSchedulesForSelectedDate();
    }
  }

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
          CustomCalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            selectedDate: _selectedDate,
            textColor: textColor,
            onDateSelected: (date) {
              _selectedDate = date;
              _loadSchedulesForSelectedDate();
            },
          ),

          Expanded(
            child: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<ScheduledWorkout> schedules = [];
                if (state is ScheduleLoaded) {
                  schedules = state.schedules;
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: media.width * 1.5,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var availWidth = (media.width * 1.2) - (80 + 40);

                        var slotsForHour = schedules.where((s) {
                          return s.scheduledTime.hour == index;
                        }).toList();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  getTime(index * 60),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

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
                      separatorBuilder: (context, index) => Divider(
                        color: TColor.gray.withOpacity(0.2),
                        height: 1,
                      ),
                      itemCount: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: InkWell(
        onTap: () async {
          final result = await navigateTo(
            context,
            BlocProvider.value(
              value: context.read<ScheduleCubit>(),
              child: AddScheduleView(date: _selectedDate),
            ),
          );

          if (result == true && mounted) {
            _loadSchedulesForSelectedDate();
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

  Widget _buildScheduleTag(
    ScheduledWorkout schedule,
    double availWidth,
    Color? textColor,
  ) {
    final timeStr = DateFormat('h:mm a').format(schedule.scheduledTime);

    return FutureBuilder<String>(
      future: _getCategoryName(schedule.categoryId),
      builder: (context, snapshot) {
        final categoryName = snapshot.data ?? 'Workout';

        return InkWell(
          onTap: () => _showScheduleOptions(schedule, categoryName),
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
              "$categoryName, $timeStr",
              maxLines: 1,
              style: TextStyle(color: TColor.white, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  void _showScheduleOptions(ScheduledWorkout schedule, String categoryName) {
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
                categoryName,
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

              RoundButton(
                title: "Hoàn thành",
                onPressed: () {
                  Navigator.pop(context);
                  _markAsCompleted(schedule.id!);
                },
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSchedule(schedule.id!);
                },
                child: Text(
                  LocaleKey.deleteScheduleButton.tr,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
