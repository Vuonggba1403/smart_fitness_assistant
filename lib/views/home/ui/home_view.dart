import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_drop_but.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/locale/translation_manager.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/bmi_card.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/daily_activity_section.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/lastest_workout_view.dart';
import '../../notifications/ui/notification_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ Lắng nghe lifecycle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Khi app resume (quay lại từ background) → Refresh
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<HomeCubit>().refreshWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger load user data khi vào HomeView
    context.read<AuthenticationCubit>().getUserData();

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        return BlocListener<HomeCubit, HomeState>(
          listener: (context, homeState) {
            if (homeState is LanguageChanged) {
              CustomDialog.show(context, message: LocaleKey.langChanged.tr);
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, homeState) {
              final theme = Theme.of(context);
              final media = MediaQuery.of(context).size;
              final textColor = theme.textTheme.bodyMedium?.color;

              // Lấy user data từ AuthenticationCubit
              final user = context.read<AuthenticationCubit>().userDataModel;

              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: homeState is! HomeLoaded
                    ? const CustomCircleProgIndicator()
                    : SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Builder(
                            builder: (context) {
                              final loadedState = homeState;
                              final hintText =
                                  loadedState.currentLanguage == 'vi'
                                  ? 'VI'
                                  : 'EN';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // === Header ===
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            LocaleKey.welcomeBack.tr,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            user?.username ?? "UserName",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          // --- DropDown chọn ngôn ngữ ---
                                          CustomDropButtonUnder(
                                            items: ["EN", "VI"],
                                            imagePaths: [
                                              "assets/img/english.png",
                                              "assets/img/vietnamese.png",
                                            ],
                                            hint: hintText,
                                            //  selectedValue: hintText,
                                            selectedValue: loadedState
                                                .currentLanguage
                                                .toUpperCase(),

                                            onChanged: (value) async {
                                              final translationManager =
                                                  Get.find<
                                                    TranslationManager
                                                  >();
                                              final homeCubit = context
                                                  .read<HomeCubit>();

                                              final localeMap = {
                                                "EN": TranslationManager
                                                    .fallbackLocaleUS,
                                                "VI": TranslationManager
                                                    .fallbackLocaleVN,
                                              };
                                              final languageMap = {
                                                "EN": "en",
                                                "VI": "vi",
                                              };

                                              if (localeMap.containsKey(
                                                value,
                                              )) {
                                                final newLang =
                                                    languageMap[value]!;
                                                await translationManager
                                                    .updateLocale(
                                                      localeMap[value]!,
                                                    );
                                                homeCubit.updateLanguage(
                                                  newLang,
                                                );
                                              }
                                            },
                                          ),

                                          // --- Nút Notification ---
                                          IconButton(
                                            onPressed: () => navigateTo(
                                              context,
                                              const NotificationView(),
                                            ),
                                            icon: Image.asset(
                                              "assets/img/notification_active.png",
                                              width: 25,
                                              height: 25,
                                              color: textColor,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: media.width * 0.05),

                                  // === BMI Card ===
                                  const BMICard(),

                                  SizedBox(height: media.width * 0.05),

                                  SizedBox(height: media.width * 0.05),

                                  // === Activity Status ===
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LocaleKey.dailyActivity.tr,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: media.width * 0.02),
                                    ],
                                  ),

                                  SizedBox(height: media.width * 0.05),

                                  // === Daily Activity ===
                                  DailyActivitySection(mediaWidth: media.width),

                                  SizedBox(height: media.width * 0.1),

                                  // === Workout Progress Chart ===
                                  SizedBox(height: media.width * 0.05),

                                  // === Latest Workout ===
                                  LatestWorkoutView(
                                    lastWorkoutArr: loadedState.lastWorkoutArr,
                                    onSeeMorePressed: () {},
                                  ),

                                  SizedBox(height: media.width * 0.1),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
