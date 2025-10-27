import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';

class UpcomingWorkoutRow extends StatelessWidget {
  final Map wObj;
  final int index;
  const UpcomingWorkoutRow({
    super.key,
    required this.wObj,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    final shadowColor = theme.shadowColor;

    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        final cubit = context.read<WorkoutTrackerCubit>();
        final toggleValue = cubit.getToggleState(index);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 2)],
          ),
          child: Row(
            children: [
              // 🖼 Ảnh workout
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  wObj["image"].toString(),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),

              // 🧾 Tiêu đề và thời gian
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wObj["title"].toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      wObj["time"].toString(),
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // 🎚 Toggle
              CustomToggleSwitch(
                value: toggleValue,
                onChanged: (val) => context
                    .read<WorkoutTrackerCubit>()
                    .toggleWorkout(index, val),
              ),
            ],
          ),
        );
      },
    );
  }
}
