import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/rarity_count_widget.dart';

/// Card hiển thị thống kê tổng quan về collection badges
///
/// Widget này tính toán và hiển thị số lượng badges theo từng rarity level:
/// - Common (Thường)
/// - Rare (Hiếm)
/// - Epic (Sử thi)
/// - Legendary (Huyền thoại)
class StatsCardWidget extends StatelessWidget {
  /// Danh sách tất cả badges để tính toán thống kê
  final List<NFTBadge> badges;

  const StatsCardWidget({Key? key, required this.badges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính toán số lượng badges theo từng rarity
    final rarityCount = _calculateRarityCount();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề thống kê
            Text(
              LocaleKey.collectionStats.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Hiển thị số lượng theo từng rarity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RarityCountWidget(
                  label: LocaleKey.common.tr,
                  count: rarityCount[BadgeRarity.common] ?? 0,
                  color: Colors.grey,
                ),
                RarityCountWidget(
                  label: LocaleKey.rare.tr,
                  count: rarityCount[BadgeRarity.rare] ?? 0,
                  color: Colors.blue,
                ),
                RarityCountWidget(
                  label: LocaleKey.epic.tr,
                  count: rarityCount[BadgeRarity.epic] ?? 0,
                  color: Colors.purple,
                ),
                RarityCountWidget(
                  label: LocaleKey.legendary.tr,
                  count: rarityCount[BadgeRarity.legendary] ?? 0,
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tính toán số lượng badges theo từng loại rarity
  ///
  /// Returns: Map với key là BadgeRarity và value là số lượng
  Map<BadgeRarity, int> _calculateRarityCount() {
    final rarityCount = <BadgeRarity, int>{};
    for (var badge in badges) {
      rarityCount[badge.rarity] = (rarityCount[badge.rarity] ?? 0) + 1;
    }
    return rarityCount;
  }
}
