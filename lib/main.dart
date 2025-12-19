import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/sensitive_data.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/views/onboarding/ui/started_view.dart';
import 'package:smart_fitness_assistant/views/schedule_management/logic/cubit/schedule_cubit.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/locale/translation_manager.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: apiKey);

  // Timezones
  tz.initializeTimeZones();

  // Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // SharedPreferences
  await AppShared.init();

  // Language
  final translationManager = TranslationManager();
  Get.put<TranslationManager>(translationManager);

  // Supabase
  await Supabase.initialize(
    url: 'https://tlmvkajvubxejucfxibw.supabase.co',
    anonKey: anonKey,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => AuthenticationCubit()),
        BlocProvider(create: (_) => WorkoutTrackerCubit()),
        BlocProvider(create: (_) => SocialFeedCubit()..loadFeed()),
        BlocProvider(create: (_) => MealPlannerCubit()),
        BlocProvider(create: (_) => ScheduleCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final translationManager = Get.find<TranslationManager>();

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return GetMaterialApp(
          title: 'Smart Fitness',
          translations: translationManager,
          locale: translationManager.locale,
          fallbackLocale: TranslationManager.fallbackLocaleVN,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const StartedView(),
        );
      },
    );
  }
}
