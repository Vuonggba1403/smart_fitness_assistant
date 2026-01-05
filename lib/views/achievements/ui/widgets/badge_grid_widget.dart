import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/badge_card_widget.dart';

/// Grid view hiển thị danh sách badges
///
/// Widget này sử dụng GridView để hiển thị badges dạng lưới
/// với 2 cột, phù hợp cho việc xem tổng quan collection.
class BadgeGridWidget extends StatelessWidget {
  /// Danh sách badges cần hiển thị
  final List<NFTBadge> badges;

  /// Callback khi user tap vào một badge
  final Function(NFTBadge) onBadgeTap;

  const BadgeGridWidget({
    Key? key,
    required this.badges,
    required this.onBadgeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Không scroll vì đã nằm trong SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      // Cấu hình grid: 2 cột, spacing 12px, tỷ lệ 0.8
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),

      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return BadgeCardWidget(badge: badge, onTap: () => onBadgeTap(badge));
      },
    );
  }
}
