import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/auth/signup/logic/cubit/signup_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/signup/ui/widgets/what_your_goal_view.dart';
import 'widgets/complete_profile_view.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SignUpForm();
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          showCustomDelightToastBar(
            context,
            LocaleKey.registerSuccess.tr,
            Icon(Icons.check, color: Colors.green),
          );
          // Navigate to home or login
          navigateTo(context, const LoginView());
        }
        if (state is SignUpError) {
          showCustomDelightToastBar(
            context,
            state.message,
            Icon(Icons.error, color: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKey.textLogin.tr,
                        style: TextStyle(
                          color: textColor?.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        LocaleKey.textRegister.tr,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),

                      RoundTextField(
                        hintText: "UserName",
                        iconPath: "assets/img/user_text.png",
                        controller: _usernameController,
                      ),
                      SizedBox(height: media.width * 0.04),
                      RoundTextField(
                        hintText: "Email",
                        iconPath: "assets/img/email.png",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: media.width * 0.04),
                      RoundTextField(
                        hintText: "Password",
                        iconPath: "assets/img/lock.png",
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      SizedBox(height: media.width * 0.04),

                      // 🔹 Register button
                      RoundButton(
                        title: LocaleKey.buttonRegis.tr,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Lưu thông tin cơ bản
                            context.read<SignupCubit>().saveBasicInfo(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              username: _usernameController.text.trim(),
                            );
                            // Hiển thị dialog complete profile
                            showCompleteProfileDialog(context);
                          }
                        },
                      ),

                      SizedBox(height: media.width * 0.04),

                      // 🔹 Or divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: textColor?.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            "  ${LocaleKey.or.tr}  ",
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: textColor?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: media.width * 0.04),

                      // 🔹 Social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            theme,
                            "assets/img/google.png",
                            cardColor,
                          ),
                          SizedBox(width: media.width * 0.04),
                          _socialButton(
                            theme,
                            "assets/img/facebook.png",
                            cardColor,
                          ),
                        ],
                      ),

                      SizedBox(height: media.width * 0.04),

                      // 🔹 Already have account
                      TextButton(
                        onPressed: () => navigateTo(context, const LoginView()),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocaleKey.haveAccount.tr,
                              style: TextStyle(color: textColor, fontSize: 14),
                            ),
                            SizedBox(width: 3),
                            Text(
                              LocaleKey.buttonLogin.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Button social login
  Widget _socialButton(ThemeData theme, String path, Color cardColor) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(width: 1, color: TColor.gray.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(path, width: 20, height: 20),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}

void showCompleteProfileDialog(BuildContext context) {
  final txtHeight = TextEditingController();
  final txtWeight = TextEditingController();
  final txtWeightGoal = TextEditingController();

  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyMedium?.color;
  final media = MediaQuery.of(context).size;
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
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
              key: _formKey,
              child: Column(
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
                      buildUnitBox("CM"),
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
                      buildUnitBox("KG"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.04),

                  // Goal Weight
                  Text(LocaleKey.textWeightGoal1.tr),
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
                      buildUnitBox("KG"),
                    ],
                  ),

                  SizedBox(height: media.width * 0.06),

                  // Button
                  RoundButton(
                    title: LocaleKey.buttonNext.tr,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Lưu thông tin profile
                        context.read<SignupCubit>().saveProfileInfo(
                          height: txtHeight.text.trim(),
                          weight: txtWeight.text.trim(),
                          weightGoal: txtWeightGoal.text.trim(),
                        );

                        // Đóng dialog và chuyển sang màn hình What Your Goal
                        Navigator.pop(context);
                        navigateTo(context, const WhatYourGoalView());
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
Widget buildUnitBox(String text) {
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
