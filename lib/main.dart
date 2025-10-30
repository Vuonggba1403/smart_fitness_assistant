import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart';
import 'package:smart_fitness_assistant/views/onboarding/ui/started_view.dart';
import 'core/functions/app_shared.dart';
import 'locale/translation_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppShared.init();

  final translationManager = TranslationManager();
  Get.put<TranslationManager>(translationManager);

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ThemeCubit())],
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
          home: const MainTabView(),
        );
      },
    );
  }
}
