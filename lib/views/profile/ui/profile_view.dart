import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_showdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'widgets/setting_row.dart';
import 'widgets/title_subtitle_cell.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
            AppSnackBar.success(context, LocaleKey.logoutSuccess.tr);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            );
          }
          if (state is LoginError) {
            AppSnackBar.error(context, LocaleKey.logoutError.tr);
          }
          if (state is DeleteAccountSuccess) {
            AppSnackBar.success(context, "Tài khoản đã được xóa thành công.");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            );
          }
          if (state is DeleteAccountError) {
            AppSnackBar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final user = context.read<AuthenticationCubit>().userDataModel;
          final isDeleting = state is DeleteAccountLoading;

          return Scaffold(
            appBar: CustomAppBar(
              title: LocaleKey.profile.tr,
              showBackButton: false,
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ----- Header -----
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                "assets/img/u1.png",
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
                                  Row(
                                    children: [
                                      Text(
                                        user?.username ?? "",
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "(${user?.age ?? ""} tuổi)",
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    user?.your_goals ?? "",
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

                        // ---- Height / Weight / Goal ----
                        Row(
                          children: [
                            Expanded(
                              child: TitleSubtitleCell(
                                title: "${user?.height ?? "--"} cm",
                                subtitle: LocaleKey.textHeight.tr,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TitleSubtitleCell(
                                title: "${user?.weight ?? "--"} kg",
                                subtitle: LocaleKey.textWeight.tr,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TitleSubtitleCell(
                                title: "${user?.weight_goal ?? "--"} kg",
                                subtitle: LocaleKey.textWeightGoal.tr,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ----- ACCOUNT SECTION -----
                        _buildSection(
                          theme,
                          title: LocaleKey.account.tr,
                          items: accountArr,
                        ),

                        const SizedBox(height: 25),

                        // ----- DARK MODE -----
                        BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, themeState) {
                            final themeCubit = context.read<ThemeCubit>();
                            return _buildDarkModeRow(
                              theme,
                              textColor,
                              isDark: themeState.isDarkMode,
                              onChanged: (value) {
                                themeCubit.toggleTheme(value);
                                CustomDialog.show(
                                  context,
                                  message: LocaleKey.changeDarkMode.tr,
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        // ----- OTHER SECTION -----
                        _buildSection(
                          theme,
                          title: LocaleKey.other.tr,
                          items: otherArr,
                        ),

                        const SizedBox(height: 25),

                        // ----- Logout -----
                        RoundButton(
                          title: LocaleKey.logout.tr,
                          onPressed: () async {
                            await context.read<AuthenticationCubit>().signOut();
                          },
                        ),

                        const SizedBox(height: 15),

                        // ----- Delete Account -----
                        RoundButton(
                          title: "Xóa tài khoản",
                          type: RoundButtonType.textGradient,
                          onPressed: isDeleting
                              ? null
                              : () {
                                  AppConfirmDialog.show(
                                    context: context,
                                    title: "Xác nhận xóa tài khoản",
                                    content:
                                        "Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác và tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.",
                                    onYes: () async {
                                      await context
                                          .read<AuthenticationCubit>()
                                          .deleteAccount();
                                    },
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay khi đang xóa
                if (isDeleting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Đang xóa tài khoản...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    final textColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(
              items.length,
              (index) => SettingRow(
                icon: items[index]["image"],
                title: items[index]["name"],
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeRow(
    ThemeData theme,
    Color? textColor, {
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
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
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
          CustomToggleSwitch(value: isDark, onChanged: onChanged),
        ],
      ),
    );
  }
}
