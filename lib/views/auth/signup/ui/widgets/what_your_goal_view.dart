import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';

import 'package:smart_fitness_assistant/locale/locale_key.dart';

class WhatYourGoalView extends StatefulWidget {
  const WhatYourGoalView({super.key});

  @override
  State<WhatYourGoalView> createState() => _WhatYourGoalViewState();
}

class _WhatYourGoalViewState extends State<WhatYourGoalView> {
  String? selectedGoal;

  List<Map<String, dynamic>> _getGoalsWithValidation(BuildContext context) {
    final cubit = context.read<AuthenticationCubit>();
    final currentWeight =
        double.tryParse(cubit.userDataModel?.weight ?? '0') ?? 0;
    final weightGoal =
        double.tryParse(cubit.userDataModel?.weight_goal ?? '0') ?? 0;

    return [
      {
        'title': 'Lose Weight',
        'icon': '🔥',
        'isValid': weightGoal < currentWeight,
      },
      {
        'title': 'Build Muscle',
        'icon': '💪',
        'isValid': weightGoal >= currentWeight,
      },
      {
        'title': 'Keep Fit',
        'icon': '🏃',
        'isValid': weightGoal == currentWeight,
      },
      {
        'title': 'Gain Weight',
        'icon': '📈',
        'isValid': weightGoal > currentWeight,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final goals = _getGoalsWithValidation(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final media = MediaQuery.of(context).size;

    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          if (!mounted) return;
          AppSnackBar.success(context, LocaleKey.registerSuccess.tr);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            }
          });
        }
        if (state is SignUpError) {
          if (!mounted) return;

          AppSnackBar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is SignUpLoading;

        return Scaffold(
          appBar: CustomAppBar(title: LocaleKey.whatYourGoal.tr),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: media.width * 0.05),
                    Text(
                      LocaleKey.whatYourGoal.tr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: media.width * 0.04),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final isValid = goal['isValid'] as bool;

                        return GestureDetector(
                          onTap: isValid
                              ? () {
                                  setState(() {
                                    selectedGoal = goal['title'];
                                  });
                                }
                              : null,
                          child: Opacity(
                            opacity: isValid ? 1.0 : 0.5,
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                vertical: media.width * 0.02,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text(
                                      goal['icon'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        goal['title'],
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (selectedGoal == goal['title'])
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // SizedBox(height: media.width * 0.1),
                    RoundButton(
                      title: isLoading
                          ? 'Loading...'
                          : LocaleKey.buttonRegis.tr,
                      onPressed: isLoading || selectedGoal == null
                          ? null
                          : () {
                              context
                                  .read<AuthenticationCubit>()
                                  .completeRegistration(
                                    yourGoals: selectedGoal!,
                                  );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
