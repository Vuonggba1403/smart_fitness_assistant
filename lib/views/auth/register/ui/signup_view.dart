import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/widgets/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/widgets/round_textfield.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';

import 'widgets/complete_profile_view.dart';
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false; // privacy policy checkbox

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey, // 🔹 Thêm form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hey there,",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const RoundTextField(
                    hintText: "UserName",
                    iconPath: "assets/img/user_text.png",
                  ),
                  const RoundTextField(
                    hintText: "Email",
                    iconPath: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  RoundTextField(
                    hintText: "Password",
                    iconPath: "assets/img/lock.png",
                    isPassword: true,
                  ),
                  SizedBox(height: media.width * 0.04),

                  // 🔹 Checkbox Privacy Policy
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        icon: Icon(
                          _isChecked
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: TColor.gray,
                          size: 20,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "By continuing you accept our Privacy Policy and Term of Use",
                          style: TextStyle(color: TColor.gray, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),

                  // 🔹 Register button
                  RoundButton(
                    title: "Register",
                    onPressed: () {
                      // 🔹 Validate form + check checkbox
                      if (_formKey.currentState!.validate() || _isChecked) {
                        if (_isChecked) {
                          navigateTo(context, const CompleteProfileView());
                        } else {}
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

                  // 🔹 Social login buttons
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

                  // 🔹 Already have account
                  TextButton(
                    onPressed: () {
                      navigateTo(context, const LoginView());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: TColor.black, fontSize: 14),
                        ),
                        Text(
                          "Login",
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
