import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import '../logic/cubit/multi_step_dialog_cubit.dart';
import 'widgets/step_activity_level.dart';
import 'widgets/step_fitness_level.dart';
import 'widgets/step_equipment.dart';
import 'widgets/step_dietary_preferences.dart';
import 'widgets/step_food_allergies.dart';
import 'widgets/step_injuries.dart';

/// Multi-step dialog để thu thập thông tin user cho workout plan
class MultiStepPlanDialog extends StatelessWidget {
  final List<ActivityLevel> activityLevels;
  final Function(ActivityLevel, UserFitnessProfile) onComplete;

  const MultiStepPlanDialog({
    super.key,
    required this.activityLevels,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultiStepDialogCubit(),
      child: _DialogContent(
        activityLevels: activityLevels,
        onComplete: onComplete,
      ),
    );
  }
}

/// Nội dung chính của dialog
class _DialogContent extends StatelessWidget {
  final List<ActivityLevel> activityLevels;
  final Function(ActivityLevel, UserFitnessProfile) onComplete;

  const _DialogContent({
    required this.activityLevels,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        final cubit = context.read<MultiStepDialogCubit>();

        return AlertDialog(
          title: _buildTitle(state),
          content: _buildContent(context, state),
          actions: _buildActions(context, state, cubit),
        );
      },
    );
  }

  /// Build title với progress
  Widget _buildTitle(MultiStepDialogState state) {
    return Row(
      children: [
        Text('Bước ${state.currentStep + 1}/6'),
        const Spacer(),
        Text(
          _getStepTitle(state.currentStep),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// Lấy title cho từng bước
  String _getStepTitle(int step) {
    const titles = [
      'Mức độ hoạt động',
      'Trình độ tập luyện',
      'Thiết bị',
      'Chế độ ăn',
      'Dị ứng',
      'Chấn thương',
    ];
    return titles[step];
  }

  /// Build nội dung dialog
  Widget _buildContent(BuildContext context, MultiStepDialogState state) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressIndicator(state),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: _buildStepContent(context, state),
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator(MultiStepDialogState state) {
    return LinearProgressIndicator(
      value: (state.currentStep + 1) / 6,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation(TColor.primaryColor1),
    );
  }

  /// Build nội dung cho từng bước
  Widget _buildStepContent(BuildContext context, MultiStepDialogState state) {
    switch (state.currentStep) {
      case 0:
        return StepActivityLevel(activityLevels: activityLevels);
      case 1:
        return const StepFitnessLevel();
      case 2:
        return const StepEquipment();
      case 3:
        return const StepDietaryPreferences();
      case 4:
        return const StepFoodAllergies();
      case 5:
        return const StepInjuries();
      default:
        return const SizedBox();
    }
  }

  /// Build action buttons
  List<Widget> _buildActions(
    BuildContext context,
    MultiStepDialogState state,
    MultiStepDialogCubit cubit,
  ) {
    return [
      if (state.currentStep > 0)
        TextButton(
          onPressed: cubit.previousStep,
          child: const Text('Quay lại'),
        ),
      if (state.currentStep < 5)
        ElevatedButton(
          onPressed: cubit.canProceed() ? cubit.nextStep : null,
          child: const Text('Tiếp tục'),
        ),
      if (state.currentStep == 5)
        ElevatedButton(
          onPressed: cubit.canComplete()
              ? () => _handleComplete(context, state, cubit)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.primaryColor1,
          ),
          child: const Text('Tạo kế hoạch'),
        ),
    ];
  }

  /// Xử lý khi hoàn thành
  void _handleComplete(
    BuildContext context,
    MultiStepDialogState state,
    MultiStepDialogCubit cubit,
  ) {
    final profile = cubit.buildFitnessProfile();
    onComplete(state.selectedActivityLevel!, profile);
  }
}
