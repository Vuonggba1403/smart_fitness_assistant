import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 3: Chọn equipment
class StepEquipment extends StatelessWidget {
  const StepEquipment({super.key});

  static final _equipment = [
    {
      'value': 'gym',
      'icon': Icons.fitness_center,
      'title': LocaleKey.gym.tr,
      'subtitle': LocaleKey.fullEquipment.tr,
    },
    {
      'value': 'home',
      'icon': Icons.home,
      'title': LocaleKey.atHome.tr,
      'subtitle': LocaleKey.minimalEquipment.tr,
    },
    {
      'value': 'mixed',
      'icon': Icons.loop,
      'title': LocaleKey.hybrid.tr,
      'subtitle': LocaleKey.hybrid.tr,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          children: _equipment.map((eq) {
            return RadioListTile<String>(
              title: Row(
                children: [
                  Icon(eq['icon'] as IconData, size: 20),
                  const SizedBox(width: 8),
                  Text(eq['title'] as String),
                ],
              ),
              subtitle: Text(eq['subtitle'] as String),
              value: eq['value'] as String,
              groupValue: state.selectedEquipment,
              onChanged: (_) => cubit.selectEquipment(eq['value'] as String),
            );
          }).toList(),
        );
      },
    );
  }
}
