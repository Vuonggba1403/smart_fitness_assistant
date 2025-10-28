import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/components/workout_row.dart';
import 'finished_workout_view.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildWorkoutList(context),
        SizedBox(height: media.width * 0.1),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context); // 🌙 Lấy theme động
    final textColor = theme.textTheme.bodyMedium?.color; // Màu text chính
    final cardColor = theme.cardColor; // Màu nền cho các card
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Latest Workout",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onSeeMorePressed,
          child: Text(
            "See More",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: lastWorkoutArr.length,
      itemBuilder: (context, index) {
        var wObj = lastWorkoutArr[index];
        return InkWell(
          onTap: () => navigateTo(context, FinishedWorkoutView()),
          child: WorkoutRow(wObj: wObj),
        );
      },
    );
  }
}
