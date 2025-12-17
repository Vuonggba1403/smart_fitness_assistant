import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';

class MealDateTimeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MealDateTimeAppBar({super.key});

  String _format(DateTime dateTime) {
    final isToday = DateUtils.isSameDay(DateTime.now(), dateTime);
    final date = isToday ? 'Hôm nay' : DateFormat('dd/MM').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    return '$date • $time';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: BlocBuilder<MealPlannerCubit, MealPlannerState>(
        builder: (context, state) {
          final dateTime = context.read<MealPlannerCubit>().selectedDateTime;

          return GestureDetector(
            onTap: () => _openWheelPicker(context, dateTime),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_format(dateTime)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openWheelPicker(BuildContext context, DateTime current) {
    DateTime tempDateTime = current;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              /// 📅 DATE PICKER
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: _getDayDifference(current),
                  ),
                  onSelectedItemChanged: (index) {
                    final newDate = DateTime.now().add(Duration(days: index));
                    tempDateTime = DateTime(
                      newDate.year,
                      newDate.month,
                      newDate.day,
                      tempDateTime.hour,
                      tempDateTime.minute,
                    );
                  },
                  children: List.generate(
                    30,
                    (i) => Center(
                      child: Text(
                        i == 0
                            ? 'Hôm nay'
                            : DateFormat(
                                'dd/MM',
                              ).format(DateTime.now().add(Duration(days: i))),
                      ),
                    ),
                  ),
                ),
              ),

              /// ⏰ TIME PICKER
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: current.hour,
                  ),
                  onSelectedItemChanged: (index) {
                    tempDateTime = DateTime(
                      tempDateTime.year,
                      tempDateTime.month,
                      tempDateTime.day,
                      index,
                      tempDateTime.minute,
                    );
                  },
                  children: List.generate(
                    24,
                    (i) => Center(
                      child: Text('${i.toString().padLeft(2, '0')}:00'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      /// ✅ Cập nhật Cubit khi picker đóng
      context.read<MealPlannerCubit>().updateDateTime(tempDateTime);
    });
  }

  /// 📌 Tính số ngày từ hôm nay
  int _getDayDifference(DateTime dateTime) {
    final today = DateTime.now();
    final difference = dateTime
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return difference.clamp(0, 29);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
