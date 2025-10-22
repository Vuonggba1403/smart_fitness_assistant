import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/tab_button.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/logic/cubit/main_tab_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/select_view.dart';
import '../../../home/ui/home_view.dart';
import '../../../photo_progress/ui/photo_progress_view.dart';
import '../../../profile/ui/profile_view.dart';

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
          return Scaffold(
            backgroundColor: TColor.white,
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
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: Icon(Icons.message, color: TColor.white, size: 35),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  color: TColor.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, -2),
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
