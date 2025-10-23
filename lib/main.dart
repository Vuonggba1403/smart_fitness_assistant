import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart';
import 'package:smart_fitness_assistant/views/profile/logic/cubit/profile_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => ProfileCubit(),
        ), // nếu ProfileCubit cần sống lâu
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'App',
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
