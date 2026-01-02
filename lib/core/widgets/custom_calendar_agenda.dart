import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

class CustomCalendarAgenda extends StatelessWidget {
  final CalendarAgendaController controller;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Color? textColor;

  const CustomCalendarAgenda({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarAgenda(
      controller: controller,
      appbar: false,
      selectedDayPosition: SelectedDayPosition.center,
      weekDay: WeekDay.short,
      dayNameFontSize: 12,
      dayNumberFontSize: 16,
      backgroundColor: Colors.transparent,
      fullCalendarScroll: FullCalendarScroll.horizontal,
      fullCalendarDay: WeekDay.short,
      selectedDateColor: const Color(0xFF1C64F2),
      dateColor: textColor ?? Colors.black,
      borderColor: Colors.grey.withOpacity(0.3),
      borderWidth: 1.0,
      initialDate: DateTime.now(),
      calendarEventColor: TColor.primaryColor2,
      firstDate: DateTime.now().subtract(const Duration(days: 140)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectedDayLogoWidget: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${selectedDate.day}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE').format(selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDateSelected: onDateSelected,
    );
  }
}
