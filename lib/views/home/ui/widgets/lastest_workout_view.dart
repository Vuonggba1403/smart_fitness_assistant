import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_section_header.dart'; // ✅ Import custom widget
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/components/workout_row.dart';

class LatestWorkoutView extends StatelessWidget {
  final List<dynamic> lastWorkoutArr;
  final VoidCallback? onSeeMorePressed;

  const LatestWorkoutView({
    Key? key,
    required this.lastWorkoutArr,
    this.onSeeMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Dùng CustomSectionHeader
        CustomSectionHeader(
          title: LocaleKey.latestWorkout.tr,
          actionText: LocaleKey.seeMore.tr,
          onActionPressed: onSeeMorePressed,
          textColor: textColor,
        ),

        // ✅ Hiển thị danh sách workout
        lastWorkoutArr.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Chưa có bài tập nào 📋",
                  style: TextStyle(
                    color: textColor?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: lastWorkoutArr.length,
                itemBuilder: (context, index) {
                  var wObj = lastWorkoutArr[index];
                  return WorkoutRow(
                    key: ValueKey('workout_$index'),
                    wObj: wObj,
                  );
                },
              ),

        SizedBox(height: media.width * 0.1),
      ],
    );
  }
}
