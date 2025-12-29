import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          AppSnackBar.success(context, LocaleKey.passwordResetSuccess.tr);
          navigateTo(context, LoginView());
        }
        if (state is PasswordResetError) {
          AppSnackBar.error(context, LocaleKey.passwordResetError.tr);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: state is PasswordResetLoading
              ? CustomCircleProgIndicator()
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppBar(title: LocaleKey.titleForgotPassword.tr),
                          SizedBox(height: 15),
                          Lottie.asset(
                            "assets/img/forgotpassword.json",
                            height: size.height * 0.25,
                          ),
                          SizedBox(height: 15),
                          Text(
                            LocaleKey.textForgotPassword.tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          RoundTextField(
                            controller: _emailController,
                            iconPath: "assets/img/email.png",
                            keyboardType: TextInputType.emailAddress,
                            hintText: LocaleKey.email.tr,
                          ),
                          SizedBox(height: size.height * 0.03),
                          RoundButton(
                            title: LocaleKey.buttonSend.tr,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // navigateTo(context, const MainTabView());
                                context
                                    .read<AuthenticationCubit>()
                                    .resetPassword(
                                      email: _emailController.text,
                                    );
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
