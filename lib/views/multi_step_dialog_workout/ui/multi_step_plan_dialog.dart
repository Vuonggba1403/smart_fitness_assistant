import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import 'package:smart_fitness_assistant/views/activity_level/ui/widgets/message_bubble.dart';
import '../logic/cubit/multi_step_dialog_cubit.dart';
import 'widgets/step_simple_widgets.dart';
import 'widgets/step_selection_widgets.dart';

class MultiStepPlanDialog extends StatefulWidget {
  final List<ActivityLevel> activityLevels;
  final Function(ActivityLevel, UserFitnessProfile) onComplete;

  const MultiStepPlanDialog({
    super.key,
    required this.activityLevels,
    required this.onComplete,
  });

  @override
  State<MultiStepPlanDialog> createState() => _MultiStepPlanDialogState();
}

class _MultiStepPlanDialogState extends State<MultiStepPlanDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return BlocProvider(
      create: (_) => MultiStepDialogCubit(),
      child: BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
        builder: (context, state) {
          final cubit = context.read<MultiStepDialogCubit>();

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            title: MessageBubble(text: LocaleKey.completeStepsInstruction.tr),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step indicator với style cải thiện
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStepIcon(state.currentStep),
                          size: 20,
                          color: TColor.primaryColor1,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              LocaleKey.activityLevel.tr,
                              LocaleKey.trainingLevel.tr,
                              LocaleKey.equipment.tr,
                              LocaleKey.dietaryRegime.tr,
                              LocaleKey.allergies.tr,
                              LocaleKey.injuries.tr,
                            ][state.currentStep],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${state.currentStep + 1}/6',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (state.currentStep + 1) / 6,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(TColor.primaryColor1),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content với shadow
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark ? 0.25 : 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: () {
                          switch (state.currentStep) {
                            case 0:
                              return StepActivityLevel(
                                activityLevels: widget.activityLevels,
                              );
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
                        }(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (state.currentStep > 0)
                TextButton(
                  onPressed: _isProcessing ? null : cubit.previousStep,
                  child: Text(LocaleKey.back.tr),
                ),
              if (state.currentStep < 5)
                ElevatedButton(
                  onPressed: (_isProcessing || !cubit.canProceed())
                      ? null
                      : cubit.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: TColor.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(LocaleKey.continue_.tr),
                ),
              if (state.currentStep == 5)
                ElevatedButton(
                  onPressed: (_isProcessing || !cubit.canComplete())
                      ? null
                      : () => _onComplete(context, cubit, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: TColor.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(TColor.white),
                          ),
                        )
                      : Text(LocaleKey.createPlan.tr),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.directions_run;
      case 1:
        return Icons.fitness_center;
      case 2:
        return Icons.sports_gymnastics;
      case 3:
        return Icons.restaurant_menu;
      case 4:
        return Icons.warning_amber_rounded;
      case 5:
        return Icons.healing;
      default:
        return Icons.check_circle;
    }
  }

  Future<void> _onComplete(
    BuildContext context,
    MultiStepDialogCubit cubit,
    MultiStepDialogState state,
  ) async {
    if (_isProcessing || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final profile = cubit.buildFitnessProfile();
      widget.onComplete(state.selectedActivityLevel!, profile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${LocaleKey.errorPrefix.tr} $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
