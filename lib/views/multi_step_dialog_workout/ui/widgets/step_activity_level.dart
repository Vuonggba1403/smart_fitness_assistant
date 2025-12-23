import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 1: Chọn activity level
class StepActivityLevel extends StatelessWidget {
  final List<ActivityLevel> activityLevels;

  const StepActivityLevel({super.key, required this.activityLevels});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          children: activityLevels.map((level) {
            return RadioListTile<ActivityLevel>(
              title: Text(level.title),
              subtitle: Text(level.description),
              value: level,
              groupValue: state.selectedActivityLevel,
              onChanged: (_) => cubit.selectActivityLevel(level),
            );
          }).toList(),
        );
      },
    );
  }
}
