import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 4: Chọn dietary preferences
class StepDietaryPreferences extends StatelessWidget {
  const StepDietaryPreferences({super.key});

  static const _preferences = [
    {'value': 'vegetarian', 'label': 'Chay (Vegetarian)'},
    {'value': 'vegan', 'label': 'Thuần chay (Vegan)'},
    {'value': 'halal', 'label': 'Halal'},
    {'value': 'keto', 'label': 'Keto'},
    {'value': 'low_carb', 'label': 'Ít tinh bột'},
    {'value': 'high_protein', 'label': 'Nhiều protein'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn các chế độ ăn phù hợp (nếu có):'),
            const SizedBox(height: 8),
            ..._preferences.map((pref) {
              return CheckboxListTile(
                title: Text(pref['label']!),
                value: state.selectedDietaryPreferences.contains(pref['value']),
                onChanged: (_) => cubit.toggleDietaryPreference(pref['value']!),
              );
            }),
            TextButton.icon(
              onPressed: cubit.clearDietaryPreferences,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Xóa tất cả'),
            ),
          ],
        );
      },
    );
  }
}
