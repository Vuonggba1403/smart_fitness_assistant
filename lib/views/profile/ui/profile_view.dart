import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_derlight_bar.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'widgets/setting_row.dart';
import 'widgets/title_subtitle_cell.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    final accountArr = [
      {"image": "assets/img/p_personal.png", "name": LocaleKey.accountArr1.tr},
      {"image": "assets/img/p_achi.png", "name": LocaleKey.accountArr2.tr},
      {"image": "assets/img/p_activity.png", "name": LocaleKey.accountArr3.tr},
      {"image": "assets/img/p_workout.png", "name": LocaleKey.accountArr4.tr},
    ];

    final otherArr = [
      {"image": "assets/img/p_contact.png", "name": LocaleKey.otherArr1.tr},
      {"image": "assets/img/p_privacy.png", "name": LocaleKey.otherArr2.tr},
      {"image": "assets/img/p_setting.png", "name": LocaleKey.otherArr3.tr},
    ];

    return BlocProvider(
      create: (context) => AuthenticationCubit()..getUserData(),
      child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            showCustomDelightToastBar(
              context,
              "Logout successful",
              Icon(Icons.check, color: Colors.green),
            );
            navigateTo(context, LoginView());
          }
          if (state is LoginError) {
            showCustomDelightToastBar(
              context,
              "Logout failed",
              const Icon(Icons.error, color: Colors.red),
            );
          }
        },
        builder: (context, state) {
          UserDataModel? user = context
              .read<AuthenticationCubit>()
              .userDataModel;
          return Scaffold(
            appBar: CustomAppBar(
              title: LocaleKey.profile.tr,
              showBackButton: false,
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: state is LogoutLoading || state is GetUserDataLoading
                ? CustomCircleProgIndicator()
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// --- Header: Avatar + Name + Edit ---
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  "assets/img/u2.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.username ?? "UserName",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "Lose a Fat Program",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                height: 25,
                                child: RoundButton(
                                  title: LocaleKey.editProfile.tr,
                                  type: RoundButtonType.bgGradient,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// --- Height / Weight / Age ---
                          Row(
                            children: [
                              Expanded(
                                child: TitleSubtitleCell(
                                  title: "${user?.height ?? ""} cm",
                                  subtitle: LocaleKey.textHeight.tr,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: TitleSubtitleCell(
                                  title: "${user?.weight ?? ""} kg",
                                  subtitle: LocaleKey.textWeight.tr,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: TitleSubtitleCell(
                                  title: "${user?.weight_goal ?? ""} kg",
                                  subtitle: LocaleKey.textWeightGoal.tr,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          /// --- Account section ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKey.account.tr,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: List.generate(accountArr.length, (
                                    index,
                                  ) {
                                    final item = accountArr[index];
                                    return SettingRow(
                                      icon: item["image"].toString(),
                                      title: item["name"].toString(),
                                      onPressed: () {},
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// --- Dark mode toggle ---
                          BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, themeState) {
                              final themeCubit = context.read<ThemeCubit>();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/img/darkmode.png",
                                      height: 15,
                                      width: 15,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        LocaleKey.darkMode.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    CustomToggleSwitch(
                                      value: themeState.isDarkMode,
                                      onChanged: (value) {
                                        themeCubit.toggleTheme(value);
                                        CustomDialog.show(
                                          context,
                                          message: LocaleKey.changeDarkMode.tr,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 25),

                          /// --- Other section ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKey.other.tr,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: List.generate(otherArr.length, (
                                    index,
                                  ) {
                                    final item = otherArr[index];
                                    return SettingRow(
                                      icon: item["image"].toString(),
                                      title: item["name"].toString(),
                                      onPressed: () {},
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// --- Logout ---
                          RoundButton(
                            title: LocaleKey.logout.tr,
                            onPressed: () async {
                              await context
                                  .read<AuthenticationCubit>()
                                  .signOut();
                              // CustomDialog.show(context, message: LocaleKey.logoutSuccess.tr);
                            },
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
