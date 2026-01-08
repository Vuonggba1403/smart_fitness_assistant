import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/views/workout_plan/ui/day_detail_page.dart';
import 'package:smart_fitness_assistant/views/workout_plan/logic/cubit/workout_plan_cubit.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Widget hiển thị calendar view của 7 ngày trong tuần
class CalendarWeekView extends StatelessWidget {
  final WorkoutPlan plan;
  final WorkoutPlanProgress? progress;
  final Function(int dayNumber) onDaySelected;
  final int? selectedDay;

  const CalendarWeekView({
    super.key,
    required this.plan,
    required this.onDaySelected,
    this.progress,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKey.thirtyDayPlan.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColor.primaryColor1,
            ),
          ),
          const SizedBox(height: 16),
          // Grid layout 7 columns (weekly format)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.7,
            ),
            itemCount: plan.dailyPlans.length,
            itemBuilder: (context, index) {
              final day = plan.dailyPlans[index];
              final dayProgress = progress?.getProgressForDay(day.dayNumber);
              final isSelected = selectedDay == day.dayNumber;

              return _buildDayCard(context, day, dayProgress, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DailyPlan day,
    DayPlanProgress? dayProgress,
    bool isSelected,
  ) {
    final isCompleted = dayProgress?.isCompleted ?? false;
    final progressPercent = dayProgress?.progressPercentage ?? 0.0;

    // Check if this is today - tính số ngày từ khi plan bắt đầu
    final now = DateTime.now();
    final planStartDate = progress?.startedAt ?? now;
    // Tính số ngày kể từ khi plan bắt đầu (zero-indexed)
    final daysSinceStart = DateTime(now.year, now.month, now.day)
        .difference(
          DateTime(planStartDate.year, planStartDate.month, planStartDate.day),
        )
        .inDays;
    // Ngày hiện tại trong plan (1-indexed)
    final currentDayNumber = daysSinceStart + 1;
    final isToday = day.dayNumber == currentDayNumber;

    return GestureDetector(
      onTap: () {
        onDaySelected(day.dayNumber);
        // Navigate to day detail page với WorkoutPlanCubit
        final cubit = context.read<WorkoutPlanCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: DayDetailPage(day: day, progress: dayProgress),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [TColor.primaryColor1, TColor.primaryColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : isToday
              ? TColor.primaryColor1.withOpacity(0.15)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isToday
                ? TColor.primaryColor1
                : isCompleted
                ? Colors.green
                : TColor.gray.withOpacity(0.3),
            width: isToday ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: TColor.primaryColor1.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            if (isToday && !isSelected)
              BoxShadow(
                color: TColor.primaryColor1.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day number
                  Text(
                    '${day.dayNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? TColor.primaryColor1
                          : TColor.primaryColor1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Day name (abbreviated)
                  Text(
                    _abbreviateDayName(day.dayName),
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : isToday
                          ? TColor.primaryColor1.withOpacity(0.8)
                          : TColor.secondaryColor1,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Completed badge
            if (isCompleted)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected || isToday ? Colors.white : Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 10,
                    color: isSelected || isToday ? Colors.green : Colors.white,
                  ),
                ),
              ),

            // Progress indicator
            if (!isCompleted && progressPercent > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: (isSelected || isToday)
                        ? Colors.white.withOpacity(0.3)
                        : TColor.gray.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (isSelected || isToday)
                          ? Colors.white
                          : TColor.primaryColor1,
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Rút gọn tên ngày (VD: "Thứ Hai" -> "T2")
  String _abbreviateDayName(String dayName) {
    if (dayName.contains('Hai')) return 'T2';
    if (dayName.contains('Ba')) return 'T3';
    if (dayName.contains('Tư')) return 'T4';
    if (dayName.contains('Năm')) return 'T5';
    if (dayName.contains('Sáu')) return 'T6';
    if (dayName.contains('Bảy')) return 'T7';
    if (dayName.contains('Nhật')) return 'CN';

    // Fallback for English
    if (dayName.toLowerCase().contains('mon')) return 'Mon';
    if (dayName.toLowerCase().contains('tue')) return 'Tue';
    if (dayName.toLowerCase().contains('wed')) return 'Wed';
    if (dayName.toLowerCase().contains('thu')) return 'Thu';
    if (dayName.toLowerCase().contains('fri')) return 'Fri';
    if (dayName.toLowerCase().contains('sat')) return 'Sat';
    if (dayName.toLowerCase().contains('sun')) return 'Sun';

    return dayName.substring(0, 2);
  }
}
