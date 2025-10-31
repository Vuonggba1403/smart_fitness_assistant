import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/onboarding/logic/cubit/onboarding_cubit.dart';
import 'package:smart_fitness_assistant/views/onboarding/ui/widgets/on_boarding_page.dart';
import 'package:get/get.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageArr = [
      {
        "title": LocaleKey.titleOnBoarding1.tr,
        "subtitle": LocaleKey.subtitleOnBoarding.tr,
        "image": "assets/img/on_1.png",
      },
      {
        "title": LocaleKey.titleOnBoarding2.tr,
        "subtitle": LocaleKey.subtitleOnBoarding2.tr,
        "image": "assets/img/on_2.png",
      },
      {
        "title": LocaleKey.titleOnBoarding3.tr,
        "subtitle": LocaleKey.subtitleOnBoarding3.tr,
        "image": "assets/img/on_3.png",
      },
      {
        "title": LocaleKey.titleOnBoarding4.tr,
        "subtitle": LocaleKey.subtitleOnBoarding4.tr,
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
