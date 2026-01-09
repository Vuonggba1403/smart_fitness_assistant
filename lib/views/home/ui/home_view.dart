import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_container_check.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_drop_but.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/locale/translation_manager.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/bmi_card.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/daily_activity_section.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/compact_streak_badge.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/lastest_workout_view.dart';
import 'package:smart_fitness_assistant/views/workout_plan/ui/workout_plan_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with WidgetsBindingObserver, RouteAware {
  final GlobalKey<CompactStreakBadgeState> _streakBadgeKey = GlobalKey();

  // Route observer để detect khi quay về trang này
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ✅ Gọi khi quay về trang này từ trang khác
  @override
  void didPopNext() {
    debugPrint('🔙 Returned to Home screen, refreshing...');
    _loadData();
  }

  // ✅ THÊM: Refresh khi app resume (từ background về foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  // ✅ Method load data - SIMPLE VERSION
  Future<void> _loadData() async {
    debugPrint('🏠 HomeView: Loading data...');

    // ✅ Chỉ cần load user data và language
    context.read<AuthenticationCubit>().getUserData();

    final cubit = context.read<HomeCubit>();
    await cubit.loadLatestWorkouts(); // ✅ Reload latest workouts
    await cubit.loadDailyActivity(); // ✅ Reload daily stats nếu có

    // ✅ Refresh streak badge khi quay lại
    debugPrint('🏠 HomeView: Refreshing streak badge...');
    _streakBadgeKey.currentState?.refreshStreak();

    // ✅ HomeCubit tự động load latest workouts trong initState
    // Không cần gọi thêm gì ở đây
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
              final media = MediaQuery.of(context).size;
              final theme = Theme.of(context);
              final textColor = theme.textTheme.bodyMedium?.color;

              // Lấy user data từ AuthenticationCubit
              final user = context.read<AuthenticationCubit>().userDataModel;

              // ✅ FIX: Check state đúng kiểu
              if (homeState is! HomeLoaded) {
                return const Scaffold(
                  body: Center(child: CustomCircleProgIndicator()),
                );
              }

              // ✅ Cast về HomeLoaded
              final loadedState = homeState;
              final hintText = loadedState.currentLanguage == 'vi'
                  ? 'VI'
                  : 'EN';

              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Header ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKey.welcomeBack.tr,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user?.username ?? "UserName",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CompactStreakBadge(key: _streakBadgeKey),
                                    ],
                                  ),
                                ],
                              ),
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
                                  selectedValue: loadedState.currentLanguage
                                      .toUpperCase(),
                                  onChanged: (value) async {
                                    final translationManager =
                                        Get.find<TranslationManager>();
                                    final homeCubit = context.read<HomeCubit>();

                                    final localeMap = {
                                      "EN": TranslationManager.fallbackLocaleUS,
                                      "VI": TranslationManager.fallbackLocaleVN,
                                    };
                                    final languageMap = {
                                      "EN": "en",
                                      "VI": "vi",
                                    };

                                    if (localeMap.containsKey(value)) {
                                      final newLang = languageMap[value]!;
                                      await translationManager.updateLocale(
                                        localeMap[value]!,
                                      );
                                      homeCubit.updateLanguage(newLang);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: media.width * 0.05),

                        // === BMI Card ===
                        const BMICard(),

                        SizedBox(height: media.width * 0.05),
                        CustomContainerCheck(
                          name: LocaleKey.startYourFirstWorkout.tr,
                          title: LocaleKey.check.tr,
                          onPressed: () {
                            navigateTo(context, WorkoutPlanView());
                          },
                        ),

                        // === Activity Status ===
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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

                        // === Latest Workout ===
                        LatestWorkoutView(
                          lastWorkoutArr: loadedState.lastWorkoutArr,
                          onSeeMorePressed: () {},
                        ),

                        SizedBox(height: media.width * 0.1),
                      ],
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
