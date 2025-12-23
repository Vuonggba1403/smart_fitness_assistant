import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 2: Chọn fitness level
class StepFitnessLevel extends StatelessWidget {
  const StepFitnessLevel({super.key});

  static const _levels = [
    {
      'value': 'beginner',
      'title': 'Mới bắt đầu',
      'subtitle': '0-6 tháng kinh nghiệm',
    },
    {
      'value': 'intermediate',
      'title': 'Trung bình',
      'subtitle': '6-24 tháng kinh nghiệm',
    },
    {
      'value': 'advanced',
      'title': 'Nâng cao',
      'subtitle': 'Hơn 2 năm kinh nghiệm',
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
