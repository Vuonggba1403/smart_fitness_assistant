import '../../../../../core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/meal_planner_view.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/workout_tracker_view.dart';
import 'package:flutter/material.dart';

import '../../../../sleep_tracker/ui/sleep_tracker_view.dart';
import '../../../../../locale/locale_key.dart';
import 'package:get/get.dart';

class SelectView extends StatelessWidget {
  const SelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundButton(
              title: LocaleKey.workoutTracker.tr,
              onPressed: () {
                navigateTo(context, WorkoutTrackerView());
              },
            ),

            const SizedBox(height: 15),

            RoundButton(
              title: LocaleKey.mealPlanner.tr,
              onPressed: () {
                navigateTo(context, MealPlannerView());
              },
            ),

            const SizedBox(height: 15),

            RoundButton(
              title: LocaleKey.sleepTracker.tr,
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
