import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/theme/logic/cubit/theme_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_alertdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_showdialog.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/login/ui/login_view.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/nft_collection_screen.dart'; // ✅ ADD
import 'package:smart_fitness_assistant/core/functions/color_extension.dart'; // ✅ ADD
import 'widgets/setting_row.dart';
import 'widgets/title_subtitle_cell.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationCubit()..getUserData(),
      child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: _handleStateListener,
        builder: (context, state) {
          final user = context.read<AuthenticationCubit>().userDataModel;
          final isDeleting = state is DeleteAccountLoading;

          return Scaffold(
            appBar: CustomAppBar(
              title: LocaleKey.profile.tr,
              showBackButton: false,
            ),
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
                        _ProfileHeader(user: user),
                        const SizedBox(height: 15),
                        _UserStatsRow(user: user),
                        const SizedBox(height: 25),
                        // ✅ ADD: NFT Collection Showcase
                        _NFTCollectionCard(),
                        const SizedBox(height: 25),
                        _SectionCard(
                          title: LocaleKey.account.tr,
                          items: [
                            {
                              "image": "assets/img/p_personal.png",
                              "name": LocaleKey.accountArr1.tr,
                            },
                            {
                              "image": "assets/img/p_achi.png",
                              "name": LocaleKey.accountArr2.tr,
                            },
                            {
                              "image": "assets/img/p_activity.png",
                              "name": LocaleKey.accountArr3.tr,
                            },
                            {
                              "image": "assets/img/p_workout.png",
                              "name": LocaleKey.accountArr4.tr,
                            },
                          ],
                        ),
                        const SizedBox(height: 25),
                        const _DarkModeRow(),
                        const SizedBox(height: 25),
                        _SectionCard(
                          title: LocaleKey.other.tr,
                          items: [
                            {
                              "image": "assets/img/p_contact.png",
                              "name": LocaleKey.otherArr1.tr,
                            },
                            {
                              "image": "assets/img/p_privacy.png",
                              "name": LocaleKey.otherArr2.tr,
                            },
                            {
                              "image": "assets/img/p_setting.png",
                              "name": LocaleKey.otherArr3.tr,
                            },
                          ],
                        ),
                        const SizedBox(height: 25),
                        _ActionButtons(isDeleting: isDeleting),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                if (isDeleting) const _LoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleStateListener(BuildContext context, AuthenticationState state) {
    if (state is LogoutSuccess || state is DeleteAccountSuccess) {
      final message = state is LogoutSuccess
          ? LocaleKey.logoutSuccess.tr
          : LocaleKey.deleteAcc.tr;
      AppSnackBar.success(context, message);
      Get.offAll(() => const LoginView());
    }
    if (state is LoginError)
      AppSnackBar.error(context, LocaleKey.logoutError.tr);
    if (state is DeleteAccountError) AppSnackBar.error(context, state.message);
  }
}

// --- PRIVATE WIDGETS ---

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
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
              Text(
                "${user?.username ?? ""} (${user?.age ?? ""} ${LocaleKey.yearOld.tr})",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                user?.your_goals ?? "",
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          height: 25,
          child: RoundButton(
            title: LocaleKey.editProfile.tr,
            type: RoundButtonType.bgGradient,
            fontSize: 12,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class _UserStatsRow extends StatelessWidget {
  final dynamic user;
  const _UserStatsRow({this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          ...items.map(
            (item) => SettingRow(
              icon: item["image"],
              title: item["name"],
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkModeRow extends StatelessWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

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
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) => CustomToggleSwitch(
              value: state.isDarkMode,
              onChanged: (v) {
                context.read<ThemeCubit>().toggleTheme(v);
                CustomDialog.show(
                  context,
                  message: LocaleKey.changeDarkMode.tr,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isDeleting;
  const _ActionButtons({required this.isDeleting});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => context.read<AuthenticationCubit>().signOut(),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: Text(
            LocaleKey.logout.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: isDeleting ? null : () => _confirmDelete(context),
          icon: const Icon(Icons.delete, color: Colors.red),
          label: Text(LocaleKey.delAcc.tr, style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    AppConfirmDialog.show(
      context: context,
      title: LocaleKey.titleAlog.tr,
      content: LocaleKey.contentAlog.tr,
      onYes: () => context.read<AuthenticationCubit>().deleteAccount(),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(LocaleKey.loading.tr, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ✅ ADD: NFT Collection Showcase Card
class _NFTCollectionCard extends StatelessWidget {
  const _NFTCollectionCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NFTCollectionScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColor.primaryColor1.withOpacity(0.3),
              TColor.primaryColor2.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: TColor.primaryColor1, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 32,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏆 NFT Badge Collection',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View your achievements',
                    style: TextStyle(
                      color: textColor?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textColor?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
