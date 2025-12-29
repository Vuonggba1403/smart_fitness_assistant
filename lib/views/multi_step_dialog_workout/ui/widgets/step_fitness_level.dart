import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 2: Chọn fitness level
class StepFitnessLevel extends StatelessWidget {
  const StepFitnessLevel({super.key});

  static final _levels = [
    {
      'value': 'beginner',
      'title': 'Mới bắt đầu',
      'subtitle': LocaleKey.beginnerSubtitle.tr,
    },
    {
      'value': 'intermediate',
      'title': 'Trung bình',
      'subtitle': LocaleKey.intermediateSubtitle.tr,
    },
    {
      'value': 'advanced',
      'title': 'Nâng cao',
      'subtitle': LocaleKey.advancedSubtitle.tr,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          children: _levels.map((level) {
            return RadioListTile<String>(
              title: Text(level['title']!),
              subtitle: Text(level['subtitle']!),
              value: level['value']!,
              groupValue: state.selectedFitnessLevel,
              onChanged: (_) => cubit.selectFitnessLevel(level['value']!),
            );
          }).toList(),
        );
      },
    );
  }
}
