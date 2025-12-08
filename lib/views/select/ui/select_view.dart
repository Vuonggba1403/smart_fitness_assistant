import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/workout_tracker_view.dart';

class SelectView extends StatelessWidget {
  const SelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKey.selectWorkout.tr)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Existing content...
            const SizedBox(height: 20),

            // Workout Tracker row
            InkWell(
              onTap: () async {
                await navigateTo(
                  context,
                  const WorkoutTrackerView(title: "Workout Tracker"),
                );

                // ✅ Refresh workout history khi quay lại
                if (context.mounted) {
                  context.read<HomeCubit>().refreshWorkouts();
                }
              },
              child: SelectRow(
                icon: "assets/img/workout_icon.png",
                title: LocaleKey.workoutTracker.tr,
                isActive: true,
              ),
            ),

            // Existing content...
          ],
        ),
      ),
    );
  }
}
