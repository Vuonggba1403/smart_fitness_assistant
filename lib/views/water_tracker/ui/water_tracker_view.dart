
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/water_tracker/logic/cubit/water_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/water_tracker/logic/water_tracker_helper.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/water_congratulations_dialog.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/water_goal_dialog.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/water_reminder_dialog.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/water_progress_display.dart';
import 'package:smart_fitness_assistant/views/water_tracker/ui/widgets/components/water_amount_selector.dart';

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaterTrackerCubit(),
      child: const _WaterTrackerContent(),
    );
  }
}

class _WaterTrackerContent extends StatefulWidget {
  const _WaterTrackerContent();

  @override
  State<_WaterTrackerContent> createState() => _WaterTrackerContentState();
}

class _WaterTrackerContentState extends State<_WaterTrackerContent> {
  int _selectedAmount = 200;

  Future<void> _handleGoalUpdate(int currentGoal) async {
    final newGoal = await WaterGoalDialog.show(context, currentGoal);

    if (newGoal != null && mounted) {
      await context.read<WaterTrackerCubit>().updateGoal(newGoal);

      if (mounted) {
        AppSnackBar.success(context, '${LocaleKey.snackBar.tr} ${newGoal}ml');
      }
    }
  }

  Future<void> _handleReminderUpdate(loadedState) async {
    final newSettings = await WaterReminderDialog.show(
      context,
      loadedState.settings,
    );

    if (newSettings != null && mounted) {
      await context.read<WaterTrackerCubit>().updateReminderSettings(
        newSettings,
      );

      if (mounted) {
        AppSnackBar.success(
          context,
            '${LocaleKey.reminder.tr} : ${newSettings.reminderIntervalMinutes} ${LocaleKey.mins.tr}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: TColor.primaryColor1,
      body: BlocListener<WaterTrackerCubit, WaterTrackerState>(
        listener: (context, state) {
          if (state is WaterGoalAchieved) {
            WaterCongratulationsDialog.show(
              context,
              state.totalMl,
              state.goalMl,
            );
          }
        },
        child: BlocBuilder<WaterTrackerCubit, WaterTrackerState>(
          builder: (context, state) {
            if (state is WaterTrackerLoading) {
              return const CustomCircleProgIndicator();
            }

            if (state is WaterTrackerError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is WaterGoalAchieved) {
              return const CustomCircleProgIndicator();
            }

            if (state is! WaterTrackerLoaded) {
              return const SizedBox.shrink();
            }

            return SafeArea(

              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: TColor.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            LocaleKey.texttitlewater.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: TColor.white),
                          onPressed: () => _handleGoalUpdate(state.goalMl),
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle
                  Expanded(
                    child: Center(
                      child: WaterProgressDisplay(
                        onTap: (){},
                        totalMl: state.totalMl,
                        goalMl: state.goalMl,
                        progress: state.progress,
                        // onTap: () => _handleGoalUpdate(state.goalMl),
                      ),
                    ),
                  ),

                  // Amount Selector
                  WaterAmountSelector(
                    selectedAmount: _selectedAmount,
                    onAmountChanged: (amount) {
                      setState(() => _selectedAmount = amount);
                    },
                  ),

                  // Next Reminder
                  InkWell(
                    onTap: () => _handleReminderUpdate(state),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            WaterTrackerHelper.getNextReminderText(
                              state.settings,
                            ),
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: TColor.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<WaterTrackerCubit>().addWaterIntake(_selectedAmount);
        },
        backgroundColor: TColor.white,
        child: Icon(Icons.add, color: TColor.primaryColor1, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
