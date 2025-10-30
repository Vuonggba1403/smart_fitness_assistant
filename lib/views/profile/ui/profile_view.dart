import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
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
    return const _ProfileBody();
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final accountArr = [
      {"image": "assets/img/p_personal.png", "name": "Personal Data"},
      {"image": "assets/img/p_achi.png", "name": "Achievement"},
      {"image": "assets/img/p_activity.png", "name": "Activity History"},
      {"image": "assets/img/p_workout.png", "name": "Workout Progress"},
    ];

    final otherArr = [
      {"image": "assets/img/p_contact.png", "name": "Contact Us"},
      {"image": "assets/img/p_privacy.png", "name": "Privacy Policy"},
      {"image": "assets/img/p_setting.png", "name": "Setting"},
    ];
    final theme = Theme.of(context); // 🌙 Lấy theme động

    return Scaffold(
      appBar: CustomAppBar(title: "Profile", showBackButton: false),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Avatar + Edit
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
                        "Stefani Wong",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
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
                  width: 70,
                  height: 25,
                  child: RoundButton(
                    title: "Edit",
                    type: RoundButtonType.bgGradient,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// Height / Weight / Age
            const Row(
              children: [
                Expanded(
                  child: TitleSubtitleCell(title: "180cm", subtitle: "Height"),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TitleSubtitleCell(title: "65kg", subtitle: "Weight"),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TitleSubtitleCell(title: "22yo", subtitle: "Age"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// Account section
            _buildSection(context, "Account", accountArr),

            const SizedBox(height: 25),

            /// Notification & Dark Mode
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return _buildDarkModeSection(context, themeState.isDarkMode);
              },
            ),

            const SizedBox(height: 25),

            /// Other section
            _buildSection(context, "Other", otherArr),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Map> items) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
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
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              var iObj = items[index];
              return SettingRow(
                icon: iObj["image"].toString(),
                title: iObj["name"].toString(),
                onPressed: () {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSection(BuildContext context, bool isDarkMode) {
    final themeCubit = context.read<ThemeCubit>();
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
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
              "Dark Mode",
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
          CustomToggleSwitch(
            value: isDarkMode,
            onChanged: themeCubit.toggleTheme,
          ),
        ],
      ),
    );
  }
}
