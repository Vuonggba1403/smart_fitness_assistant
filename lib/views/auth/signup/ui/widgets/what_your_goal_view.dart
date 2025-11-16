import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
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
  String selectedGoal = '';

  final List<Map<String, String>> goals = [
    {'title': 'Lose Weight', 'icon': '🔥'},
    {'title': 'Build Muscle', 'icon': '💪'},
    {'title': 'Keep Fit', 'icon': '🏃'},
    {'title': 'Gain Weight', 'icon': '📈'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          if (!mounted) return;

          showCustomDelightToastBar(
            context,
            LocaleKey.registerSuccess.tr,
            Icon(Icons.check, color: Colors.green),
          );

          // ✅ Navigate an toàn
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            );
          });
        }
        if (state is SignUpError) {
          if (!mounted) return;

          showCustomDelightToastBar(
            context,
            state.message,
            Icon(Icons.error, color: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SignUpLoading;

        return Scaffold(
          appBar: CustomAppBar(title: LocaleKey.whatYourGoal.tr),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Select your fitness goal',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final isSelected = selectedGoal == goal['title'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = goal['title']!;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.1)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.dividerColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                goal['icon']!,
                                style: TextStyle(fontSize: 30),
                              ),
                              SizedBox(width: 15),
                              Text(
                                goal['title']!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                RoundButton(
                  title: isLoading ? 'Loading...' : LocaleKey.buttonRegis.tr,
                  onPressed: isLoading || selectedGoal.isEmpty
                      ? null
                      : () {
                          context
                              .read<AuthenticationCubit>()
                              .completeRegistration(yourGoals: selectedGoal);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
