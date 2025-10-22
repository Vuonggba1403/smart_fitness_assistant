import '../../../../core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/naviga_to.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/meal_planner_view.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/workout_tracker_view.dart';
import 'package:flutter/material.dart';

import '../../../sleep_tracker/sleep_tracker_view.dart';

class SelectView extends StatelessWidget {
  const SelectView({super.key});

  @override
  Widget build(BuildContext context) {
    // var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundButton(
              title: "Workout Tracker",
              onPressed: () {
                navigateTo(context, WorkoutTrackerView());
              },
            ),

            const SizedBox(height: 15),

            RoundButton(
              title: "Meal Planner",
              onPressed: () {
                navigateTo(context, MealPlannerView());
              },
            ),

            const SizedBox(height: 15),

            RoundButton(
              title: "Sleep Tracker",
              onPressed: () {
                navigateTo(context, SleepTrackerView());
              },
            ),
          ],
        ),
      ),
    );
  }
}
