import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import '../../../../../core/functions/colo_extension.dart';

class UpcomingWorkoutRow extends StatelessWidget {
  final Map wObj;
  const UpcomingWorkoutRow({super.key, required this.wObj});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    final shadowColor = theme.shadowColor;

    return BlocBuilder<WorkoutTrackerCubit, Map<String, bool>>(
      builder: (context, state) {
        final isOn =
            state[wObj["id"]] ?? false; // trạng thái hiện tại của toggle

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
                key: ValueKey(wObj["id"]),
                value: isOn,
                onChanged: (val) {
                  context.read<WorkoutTrackerCubit>().setWorkout(
                    wObj["id"].toString(),
                    val,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
