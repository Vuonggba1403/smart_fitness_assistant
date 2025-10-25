import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/onboarding/logic/cubit/onboarding_cubit.dart';
import 'package:smart_fitness_assistant/views/onboarding/ui/widgets/on_boarding_page.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageArr = [
      {
        "title": "Track Your Goal",
        "subtitle":
            "Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals",
        "image": "assets/img/on_1.png",
      },
      {
        "title": "Get Burn",
        "subtitle":
            "Let’s keep burning, to achieve your goals. It hurts only temporarily — if you give up now, you will be in pain forever.",
        "image": "assets/img/on_2.png",
      },
      {
        "title": "Eat Well",
        "subtitle":
            "Let's start a healthy lifestyle with us. We can determine your diet every day — healthy eating is fun!",
        "image": "assets/img/on_3.png",
      },
      {
        "title": "Improve Sleep\nQuality",
        "subtitle":
            "Improve your sleep quality with us. Good quality sleep brings a good mood in the morning.",
        "image": "assets/img/on_4.png",
      },
    ];

    final controller = PageController();

    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, int>(
        builder: (context, selectPage) {
          final cubit = context.read<OnboardingCubit>();
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // --- PageView ---
                PageView.builder(
                  controller: controller,
                  itemCount: pageArr.length,
                  onPageChanged: cubit.changePage,
                  itemBuilder: (context, index) {
                    final pObj = pageArr[index];
                    return OnBoardingPage(pObj: pObj);
                  },
                ),

                // --- Next button with circular progress ---
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            color: TColor.primaryColor1,
                            value: (selectPage + 1) / pageArr.length,
                            strokeWidth: 2,
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: TColor.primaryColor1,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.navigate_next,
                              color: TColor.white,
                            ),
                            onPressed: () {
                              if (selectPage < pageArr.length - 1) {
                                controller.animateToPage(
                                  selectPage + 1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn,
                                );
                                cubit.nextPage(pageArr.length);
                              } else {
                                navigateTo(context, const LoginView());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
