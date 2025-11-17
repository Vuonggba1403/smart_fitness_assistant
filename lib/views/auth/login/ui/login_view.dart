import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/forgot_password_view.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart';
import 'package:smart_fitness_assistant/views/auth/signup/ui/signup_view.dart';

import '../../../../core/widgets/round_button.dart';

class LoginView extends StatefulWidget {
  final bool showSignUpSuccess;

  const LoginView({super.key, this.showSignUpSuccess = false});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ Hiển thị success message sau khi widget đã build xong
    if (widget.showSignUpSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        showCustomDelightToastBar(
          context,
          'Registration successful! Please login.',
          Icon(Icons.check_circle, color: Colors.green),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        log('🔄 Login State: ${state.runtimeType}');

        if (state is LoginError) {
          log('❌ Error: ${state.message}');

          if (!mounted) return;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            showCustomDelightToastBar(
              context,
              state.message,
              Icon(Icons.error, color: Colors.red),
            );
          });
        }

        if (state is LoginSuccess) {
          log('✅ Login Success - Navigating to MainTabView');

          if (!mounted) return;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabView()),
              (route) => false,
            );
          });
        }
      },
      builder: (context, state) {
        AuthenticationCubit cubit = context.read<AuthenticationCubit>();
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: state is LoginLoading
              ? CustomCircleProgIndicator()
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: media.height * 0.9,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKey.textLogin.tr,
                              style: TextStyle(
                                color: textColor?.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              LocaleKey.welcomeBack.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: media.width * 0.09),
                            RoundTextField(
                              controller: _emailController,
                              iconPath: "assets/img/email.png",
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Email',
                            ),
                            SizedBox(height: media.width * 0.04),
                            RoundTextField(
                              controller: _passwordController,
                              hintText: "Password",
                              iconPath: "assets/img/lock.png",
                              isPassword: true,
                            ),
                            SizedBox(height: media.width * 0.02),
                            // const Spacer(),
                            // Forgot Password Button
                            GestureDetector(
                              onTap: () {
                                navigateTo(context, ForgotPasswordView());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    LocaleKey.forgotPassword.tr,
                                    style: TextStyle(
                                      color: textColor?.withOpacity(0.8),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Login Button
                            RoundButton(
                              title: LocaleKey.buttonLogin.tr,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // navigateTo(context, const MainTabView());
                                  cubit.login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                }
                              },
                            ),

                            SizedBox(height: media.width * 0.04),
                            //Phan tach button
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: TColor.gray.withOpacity(0.5),
                                  ),
                                ),
                                Text(
                                  "  ${LocaleKey.or.tr}  ",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: TColor.gray.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: media.width * 0.04),
                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      border: Border.all(
                                        width: 1,
                                        color: TColor.gray.withOpacity(0.4),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Image.asset(
                                      "assets/img/google.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(width: media.width * 0.04),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      border: Border.all(
                                        width: 1,
                                        color: TColor.gray.withOpacity(0.4),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Image.asset(
                                      "assets/img/facebook.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: media.width * 0.04),
                            // Don't have an account
                            TextButton(
                              onPressed: () {
                                // Navigator.pop(context);
                                navigateTo(context, SignUpView());
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKey.dontAccount.tr,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    LocaleKey.buttonRegis.tr,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
