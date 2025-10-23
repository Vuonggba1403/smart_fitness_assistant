import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/tab_button.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/logic/cubit/main_tab_cubit.dart';
import '../../../home/ui/home_view.dart';
import '../../../photo_progress/ui/photo_progress_view.dart';
import '../../../profile/ui/profile_view.dart';
import '../ui/select_view.dart';

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeView(),
      const SelectView(),
      const PhotoProgressView(),
      const ProfileView(),
    ];

    return BlocProvider(
      create: (_) => MainTabCubit(),
      child: BlocBuilder<MainTabCubit, MainTabState>(
        builder: (context, state) {
          final cubit = context.watch<MainTabCubit>();
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
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
                    gradient: LinearGradient(colors: context.primaryGradient),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.message,
                    color: isDark ? TColor.white : TColor.black,
                    size: 35,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: theme.bottomAppBarTheme.color ?? theme.cardColor,
              child: Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.white10 : Colors.black12,
                      blurRadius: 2,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTabButton(
                      context,
                      cubit,
                      0,
                      "home_tab.png",
                      "home_tab_select.png",
                    ),
                    _buildTabButton(
                      context,
                      cubit,
                      1,
                      "activity_tab.png",
                      "activity_tab_select.png",
                    ),
                    const SizedBox(width: 40),
                    _buildTabButton(
                      context,
                      cubit,
                      2,
                      "camera_tab.png",
                      "camera_tab_select.png",
                    ),
                    _buildTabButton(
                      context,
                      cubit,
                      3,
                      "profile_tab.png",
                      "profile_tab_select.png",
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

  //Tab
  Expanded _buildTabButton(
    BuildContext context,
    MainTabCubit cubit,
    int index,
    String icon,
    String selectIcon,
  ) {
    return Expanded(
      child: TabButton(
        icon: "assets/img/$icon",
        selectIcon: "assets/img/$selectIcon",
        isActive: cubit.currentIndex == index,
        onTap: () => cubit.changeCurrentIndex(index),
      ),
    );
  }
}
