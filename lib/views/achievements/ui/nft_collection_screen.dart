import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_state.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/empty_state_widget.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/stats_card_widget.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/badge_grid_widget.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/badge_details_bottom_sheet.dart';

/// Screen hiển thị NFT Badge Collection của user
///
/// Screen này cho phép user:
/// - Xem tất cả badges đã earned
/// - Xem thống kê collection (số lượng theo rarity)
/// - Xem badges được showcase
/// - Tap vào badge để xem chi tiết
/// - Share badges
/// - Toggle showcase status
class NFTCollectionScreen extends StatelessWidget {
  const NFTCollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.nftBadgeCollection.tr),
      body: BlocBuilder<AchievementCubit, AchievementState>(
        builder: (context, state) {
          // Hiển thị empty state nếu chưa có badges
          if (state.badges.isEmpty) {
            return const EmptyStateWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Summary Card
                StatsCardWidget(badges: state.badges),
                const SizedBox(height: 24),

                // Showcased Badges Section
                if (state.showcasedBadges.isNotEmpty) ...[
                  Text(
                    LocaleKey.showcased.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  BadgeGridWidget(
                    badges: state.showcasedBadges,
                    onBadgeTap: (badge) => _handleBadgeTap(context, badge),
                  ),
                  const SizedBox(height: 24),
                ],

                // All Badges Section
                Text(
                  '${LocaleKey.allBadges.tr} (${state.badges.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                BadgeGridWidget(
                  badges: state.badges,
                  onBadgeTap: (badge) => _handleBadgeTap(context, badge),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Xử lý khi user tap vào một badge
  ///
  /// Hiển thị bottom sheet với chi tiết đầy đủ của badge
  void _handleBadgeTap(BuildContext context, badge) {
    BadgeDetailsBottomSheet.show(context, badge);
  }
}
