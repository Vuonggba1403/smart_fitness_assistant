import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
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

          // 🟢 Lấy theme hiện tại
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
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
                      colors: isDark
                          ? [TColor.secondaryColor1, TColor.secondaryColor2]
                          : [TColor.primaryColor1, TColor.primaryColor2],
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
                        icon: "assets/img/home_tab.png",
                        selectIcon: "assets/img/home_tab_select.png",
                        isActive: cubit.currentIndex == 0,
                        onTap: () => cubit.changeCurrentIndex(0),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/activity_tab.png",
                        selectIcon: "assets/img/activity_tab_select.png",
                        isActive: cubit.currentIndex == 1,
                        onTap: () => cubit.changeCurrentIndex(1),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/camera_tab.png",
                        selectIcon: "assets/img/camera_tab_select.png",
                        isActive: cubit.currentIndex == 2,
                        onTap: () => cubit.changeCurrentIndex(2),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
                        icon: "assets/img/profile_tab.png",
                        selectIcon: "assets/img/profile_tab_select.png",
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
