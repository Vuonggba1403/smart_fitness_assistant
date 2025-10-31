import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'on_boarding_view.dart';
import 'package:get/get.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView>
    with SingleTickerProviderStateMixin {
  bool isChangeColor = false;

  @override
  void initState() {
    super.initState();

    // ⏳ Sau khi widget được dựng, tự đổi màu sau 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        isChangeColor = true;
      });
    });

    // 🚀 Sau 2 giây (sau khi đổi màu), tự động chuyển sang OnBoardingView
    Future.delayed(const Duration(seconds: 2), () {
      navigateTo(context, const OnBoardingView());
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedContainer(
        duration: const Duration(seconds: 2), // ⏳ thời gian đổi màu
        width: media.width,
        decoration: BoxDecoration(
          gradient: isChangeColor
              ? LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(colors: [Colors.white, Colors.white]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "Fitness",
              style: TextStyle(
                color: isChangeColor ? Colors.white : TColor.black,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              LocaleKey.textOnboarding.tr,
              style: TextStyle(
                color: isChangeColor ? Colors.white70 : TColor.gray,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
