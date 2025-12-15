import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/widgets/tab_button.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/logic/cubit/main_tab_cubit.dart';
import 'package:smart_fitness_assistant/views/social/ui/social_feed_screen.dart';
import '../../../home/ui/home_view.dart';
import '../../../profile/ui/profile_view.dart';
import 'widgets/select_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  @override
  void initState() {
    super.initState();
    // Load user data một lần khi app khởi động
    context.read<AuthenticationCubit>().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeView(),
      const SelectView(),
      const SocialFeedScreen(),
      const ProfileView(),
    ];

    return BlocProvider(
      create: (_) => MainTabCubit(),
      child: BlocBuilder<MainTabCubit, MainTabState>(
        builder: (context, state) {
          final cubit = context.watch<MainTabCubit>();

          // 🟢 Lấy theme hiện tại
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            // ✅ Thêm key dựa trên locale để rebuild khi đổi ngôn ngữ
            key: ValueKey(Get.locale?.languageCode ?? 'en'),

            // 🟢 Dùng màu theo theme
            backgroundColor: theme.scaffoldBackgroundColor,

            body: PageStorage(
              bucket: PageStorageBucket(),
              child: pages[cubit.currentIndex],
            ),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: SizedBox(
              width: 70,
              height: 70,
              child: InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.gradientColors(context),
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.message,
                    color: isDark ? TColor.white : TColor.white,
                    size: 35,
                  ),
                ),
              ),
            ),

            // 🟢 Bottom bar đổi màu theo theme
            bottomNavigationBar: BottomAppBar(
              color: theme.bottomAppBarTheme.color ?? theme.cardColor,
              child: Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white10
                          : Colors.black12, // khác giữa 2 theme
                      blurRadius: 2,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/home.png",
                        selectIcon: "assets/img/home_select.png",
                        isActive: cubit.currentIndex == 0,
                        onTap: () => cubit.changeCurrentIndex(0),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/choice.png",
                        selectIcon: "assets/img/choice_select.png",
                        isActive: cubit.currentIndex == 1,
                        onTap: () => cubit.changeCurrentIndex(1),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/social-media.png",
                        selectIcon: "assets/img/social-media_select.png",
                        isActive: cubit.currentIndex == 2,
                        onTap: () => cubit.changeCurrentIndex(2),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/user.png",
                        selectIcon: "assets/img/user_select.png",
                        isActive: cubit.currentIndex == 3,
                        onTap: () => cubit.changeCurrentIndex(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
