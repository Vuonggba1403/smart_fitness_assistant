import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'on_boarding_view.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  SupabaseClient client = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _navigateToOnBoarding();
  }

  void _navigateToOnBoarding() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      navigateTo(
        context,
        client.auth.currentUser != null
            ? const MainTabView()
            : const OnBoardingView(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        width: media.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppTheme.gradientColors(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "Fitness",
              style: TextStyle(
                color: textColor,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              LocaleKey.textOnboarding.tr,
              style: TextStyle(
                color: textColor?.withOpacity(0.7),
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
