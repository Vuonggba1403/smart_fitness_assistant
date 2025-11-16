import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/signup/ui/widgets/what_your_goal_view.dart';

void showCompleteProfileDialog(BuildContext context) {
  final txtHeight = TextEditingController();
  final txtWeight = TextEditingController();
  final txtWeightGoal = TextEditingController();

  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyMedium?.color;
  final media = MediaQuery.of(context).size;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: media.height * 0.66,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          decoration: BoxDecoration(
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
                          iconPath: "assets/img/hight.png",
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

                  // Button
                  RoundButton(
                    title: LocaleKey.buttonNext.tr,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // ✅ Sử dụng context gốc (không phải dialogContext)
                        context.read<AuthenticationCubit>().saveProfileInfo(
                          height: txtHeight.text.trim(),
                          weight: txtWeight.text.trim(),
                          weightGoal: txtWeightGoal.text.trim(),
                        );

                        // ✅ Đóng dialog
                        Navigator.of(dialogContext).pop();

                        // ✅ Navigate sau khi dialog đóng
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            navigateTo(context, const WhatYourGoalView());
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
      );
    },
  );
}

// Widget phụ: đơn vị "CM", "KG"
Widget _buildUnitBox(String text) {
  return Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: TColor.secondaryG),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(text, style: TextStyle(color: TColor.white, fontSize: 12)),
  );
}
