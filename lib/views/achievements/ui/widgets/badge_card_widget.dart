import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/utils/badge_rarity_utils.dart';

/// Card hiển thị thông tin tóm tắt của một badge
///
/// Widget này hiển thị:
/// - Icon badge với màu sắc theo rarity
/// - Tên badge
/// - Rarity badge label
/// - Icon star nếu badge được showcase
class BadgeCardWidget extends StatelessWidget {
  /// Badge cần hiển thị
  final NFTBadge badge;

  /// Callback khi user tap vào card
  final VoidCallback onTap;

  const BadgeCardWidget({Key? key, required this.badge, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarityColor = BadgeRarityUtils.getColor(badge.rarity);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Màu nền theo rarity với opacity
        color: rarityColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Icon với màu rarity
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 60,
                    color: rarityColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tên badge
              Text(
                badge.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Rarity Badge Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge.rarity.localized.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),

              // Icon star cho showcased badges
              if (badge.isShowcased)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.star, size: 16, color: Colors.amber),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
