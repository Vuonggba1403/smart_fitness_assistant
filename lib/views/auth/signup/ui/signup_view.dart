import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/auth/signup/logic/cubit/signup_cubit.dart';
import 'widgets/complete_profile_view.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: const _SignUpForm(),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

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
                    "Hey there,",
                    style: TextStyle(
                      color: textColor?.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),

                  const RoundTextField(
                    hintText: "UserName",
                    iconPath: "assets/img/user_text.png",
                  ),
                  SizedBox(height: media.width * 0.04),
                  const RoundTextField(
                    hintText: "Email",
                    iconPath: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: media.width * 0.04),
                  const RoundTextField(
                    hintText: "Password",
                    iconPath: "assets/img/lock.png",
                    isPassword: true,
                  ),
                  SizedBox(height: media.width * 0.04),

                  // 🔹 Checkbox Privacy Policy
                  BlocBuilder<SignUpCubit, SignUpState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                context.read<SignUpCubit>().toggleCheck(),
                            icon: Icon(
                              state.isChecked
                                  ? Icons.check_box_outlined
                                  : Icons.check_box_outline_blank_outlined,
                              color: TColor.gray,
                              size: 20,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "By continuing you accept our Privacy Policy and Term of Use",
                              style: TextStyle(
                                color: textColor?.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: media.width * 0.05),

                  // 🔹 Register button
                  BlocBuilder<SignUpCubit, SignUpState>(
                    builder: (context, state) {
                      return RoundButton(
                        title: "Register",
                        onPressed: () {
                          if (!state.isChecked) {
                            // Show toast yêu cầu check
                            showCustomDelightToastBar(
                              context,
                              "Check the box to continue",
                              Icon(Icons.info_outline, color: textColor),
                            );
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            navigateTo(context, const CompleteProfileView());
                          }
                        },
                      );
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
                        "  Or  ",
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
                      _socialButton(theme, "assets/img/google.png", cardColor),
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
                          "Already have an account? ",
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        Text(
                          "Login",
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
  }

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
}
