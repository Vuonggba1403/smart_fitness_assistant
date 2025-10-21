import 'package:smart_fitness_assistant/common_widget/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart';
import 'package:smart_fitness_assistant/views/home/ui/home_view.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/widgets/complete_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
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
                    "Hey there,",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  SizedBox(height: media.width * 0.04),
                  const RoundTextField(
                    iconPath: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    hintText: "Password",
                    iconPath: "assets/img/lock.png",
                    isPassword: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  RoundButton(
                    title: "Login",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        navigateTo(context, const MainTabView());
                      }
                    },
                  ),

                  SizedBox(height: media.width * 0.04),
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
                        "  Or  ",
                        style: TextStyle(color: TColor.black, fontSize: 12),
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
                            color: TColor.white,
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
                            color: TColor.white,
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
                  TextButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      navigateTo(context, SignUpView());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don’t have an account yet? ",
                          style: TextStyle(color: TColor.black, fontSize: 14),
                        ),
                        Text(
                          "Register",
                          style: TextStyle(
                            color: TColor.black,
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
}
