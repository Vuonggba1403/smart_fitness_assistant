import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 3: Chọn equipment
class StepEquipment extends StatelessWidget {
  const StepEquipment({super.key});

  static const _equipment = [
    {
      'value': 'gym',
      'icon': Icons.fitness_center,
      'title': 'Phòng gym',
      'subtitle': 'Có đầy đủ thiết bị',
    },
    {
      'value': 'home',
      'icon': Icons.home,
      'title': 'Tại nhà',
      'subtitle': 'Thiết bị tối thiểu',
    },
    {
      'value': 'mixed',
      'icon': Icons.loop,
      'title': 'Kết hợp',
      'subtitle': 'Gym + Home',
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
