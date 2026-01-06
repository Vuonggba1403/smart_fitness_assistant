import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// ✨ Gộp 4 step widgets đơn giản vào 1 file

// ========== Step 1: Activity Level ==========
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

// ========== Step 2: Fitness Level ==========
class StepFitnessLevel extends StatelessWidget {
  const StepFitnessLevel({super.key});

  static final _levels = [
    {
      'value': 'beginner',
      'titleKey': LocaleKey.beginnerTitle,
      'subtitleKey': LocaleKey.beginnerSubtitle,
    },
    {
      'value': 'intermediate',
      'titleKey': LocaleKey.intermediateTitle,
      'subtitleKey': LocaleKey.intermediateSubtitle,
    },
    {
      'value': 'advanced',
      'titleKey': LocaleKey.advancedTitle,
      'subtitleKey': LocaleKey.advancedSubtitle,
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
              title: Text(level['titleKey']!.tr),
              subtitle: Text(level['subtitleKey']!.tr),
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

// ========== Step 3: Equipment ==========
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

// ========== Step 4: Dietary Preferences ==========
class StepDietaryPreferences extends StatelessWidget {
  const StepDietaryPreferences({super.key});

  static final _preferences = [
    {'value': 'vegetarian', 'labelKey': LocaleKey.vegetarianLabel},
    {'value': 'vegan', 'labelKey': LocaleKey.veganLabel},
    {'value': 'halal', 'labelKey': LocaleKey.halalLabel},
    {'value': 'keto', 'labelKey': LocaleKey.ketoLabel},
    {'value': 'low_carb', 'labelKey': LocaleKey.starchless},
    {'value': 'high_protein', 'labelKey': LocaleKey.highProteinLabel},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKey.selectDietaryPreferences.tr),
            const SizedBox(height: 8),
            ..._preferences.map((pref) {
              return CheckboxListTile(
                title: Text(pref['labelKey']!.tr),
                value: state.selectedDietaryPreferences.contains(pref['value']),
                onChanged: (_) => cubit.toggleDietaryPreference(pref['value']!),
              );
            }),
            TextButton.icon(
              onPressed: cubit.clearDietaryPreferences,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(LocaleKey.clearAll.tr),
            ),
          ],
        );
      },
    );
  }
}
