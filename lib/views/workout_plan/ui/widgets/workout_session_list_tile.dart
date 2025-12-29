import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/workout_plan.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

/// Widget hiển thị một workout session trong list
class WorkoutSessionListTile extends StatelessWidget {
  final WorkoutSession workout;

  const WorkoutSessionListTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLeading(),
      title: Text(
        workout.exercise.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailing(context),
    );
  }

  /// Build leading image
  Widget _buildLeading() {
    if (workout.exercise.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        workout.exercise.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fitness_center, color: Colors.grey),
    );
  }

  /// Build subtitle với thông tin sets/reps
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '${workout.sets} sets × ${workout.reps} reps'
          '${workout.durationMinutes != null ? " • ${workout.durationMinutes} phút" : ""}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          workout.exercise.muscleGroupsString,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build trailing icon button
  Widget _buildTrailing(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.info_outline, color: TColor.primaryColor1, size: 24),
      onPressed: () {
        ExerciseDetailBottomSheet.show(context, workout.exercise);
      },
      tooltip: 'Xem chi tiết',
    );
  }
}
