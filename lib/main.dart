import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/sensitive_data.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';

import 'package:smart_fitness_assistant/views/home/logic/cubit/home_cubit.dart';
import 'package:smart_fitness_assistant/views/onboarding/ui/started_view.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'core/functions/app_shared.dart';
import 'locale/translation_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Khởi tạo timezone TRƯỚC khi chạy app
  tz.initializeTimeZones();

  // ✅ Khởi tạo notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  //Khoi tao SharedPreferences
  await AppShared.init();
  //Khoi tao da ngon ngu
  final translationManager = TranslationManager();
  Get.put<TranslationManager>(translationManager);
  //Connect to Supabase
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
        BlocProvider(
          create: (_) => SocialFeedCubit()..loadFeed(), // ✅ THÊM: ..loadFeed()
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
