import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/signup/ui/widgets/what_your_goal_view.dart';

// ✅ THÊM: Check context trước khi show dialog
void showCompleteProfileDialog(BuildContext context) {
  // ✅ CHECK: Context còn mounted
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CompleteProfileDialog(
      parentContext: context, // ✅ THÊM: Pass parent context
    ),
  );
}

class CompleteProfileDialog extends StatefulWidget {
  final BuildContext parentContext;

  const CompleteProfileDialog({Key? key, required this.parentContext})
    : super(key: key);

  @override
  State<CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

class _CompleteProfileDialogState extends State<CompleteProfileDialog> {
  final txtHeight = TextEditingController();
  final txtWeight = TextEditingController();
  final txtWeightGoal = TextEditingController();
  final txtAge = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    txtHeight.dispose();
    txtWeight.dispose();
    txtWeightGoal.dispose();
    txtAge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final media = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Container(
          constraints: BoxConstraints(maxHeight: media.height * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          decoration: BoxDecoration(
            color: theme.dialogBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKey.titleCompleteProfile.tr,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    LocaleKey.textCompleteProfile.tr,
                    style: TextStyle(
                      color: textColor?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),

                  // Your Height
                  Text(LocaleKey.textHeight1.tr),
                  SizedBox(height: media.width * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: RoundTextField(
                          controller: txtHeight,
                          hintText: LocaleKey.hintHeight.tr,
                          keyboardType: TextInputType.number,
                          iconPath: "assets/img/height.png",
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUnitBox("CM"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.04),

                  // Your Weight
                  Text(LocaleKey.textWeight1.tr),
                  SizedBox(height: media.width * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: RoundTextField(
                          controller: txtWeight,
                          hintText: LocaleKey.hintWeight.tr,
                          keyboardType: TextInputType.number,
                          iconPath: "assets/img/weight.png",
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUnitBox("KG"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.04),

                  // Goal Weight
                  Text(LocaleKey.textWeightGoal.tr),
                  SizedBox(height: media.width * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: RoundTextField(
                          controller: txtWeightGoal,
                          hintText: LocaleKey.hintWeightGoal.tr,
                          keyboardType: TextInputType.number,
                          iconPath: "assets/img/weight.png",
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUnitBox("KG"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.06),

                  // Age
                  Text(LocaleKey.textAge.tr),
                  SizedBox(height: media.width * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: RoundTextField(
                          controller: txtAge,
                          hintText: LocaleKey.hintAge.tr,
                          keyboardType: TextInputType.number,
                          iconPath: "assets/img/age.png",
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUnitBox("YEARS"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.08),

                  // Button
                  RoundButton(
                    title: LocaleKey.buttonNext.tr,
                    onPressed: () {
                      // Validate age
                      final age = int.tryParse(txtAge.text.trim());
                      if (age == null || age < 0 || age > 100) {
                        return;
                      }

                      if (formKey.currentState!.validate()) {
                        // Đóng bàn phím trước khi thực hiện navigation
                        FocusScope.of(context).unfocus();

                        widget.parentContext
                            .read<AuthenticationCubit>()
                            .saveProfileInfo(
                              height: txtHeight.text.trim(),
                              weight: txtWeight.text.trim(),
                              weightGoal: txtWeightGoal.text.trim(),
                              age: txtAge.text.trim(),
                            );

                        Navigator.of(context).pop();

                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (widget.parentContext.mounted) {
                            navigateTo(
                              widget.parentContext,
                              const WhatYourGoalView(),
                            );
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget unit box
Widget _buildUnitBox(String text) {
  return Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: TColor.secondaryG),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
