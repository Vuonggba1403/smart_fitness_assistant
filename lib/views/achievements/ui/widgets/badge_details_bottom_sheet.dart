import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/utils/badge_rarity_utils.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/widgets/share_to_feed_dialog.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

/// Bottom sheet hiển thị chi tiết đầy đủ của một badge
///
/// Bottom sheet này bao gồm:
/// - Icon và tên badge
/// - Thông tin metadata (workout type, exercises, duration, calories)
/// - Thông tin NFT (token ID, minted date)
/// - Actions: Showcase/Unshowcase, Share, Post to Feed
class BadgeDetailsBottomSheet extends StatelessWidget {
  /// Badge cần hiển thị chi tiết
  final NFTBadge badge;

  const BadgeDetailsBottomSheet({Key? key, required this.badge})
    : super(key: key);

  /// Static method để show bottom sheet
  ///
  /// [context] BuildContext để show bottom sheet
  /// [badge] Badge cần hiển thị
  static void show(BuildContext context, NFTBadge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BadgeDetailsBottomSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = BadgeRarityUtils.getColor(badge.rarity);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Badge Icon & Name
          _buildHeader(context, rarityColor),
          const SizedBox(height: 24),

          // Workout Details Section
          _buildWorkoutDetailsSection(context),

          const Divider(),

          // NFT Information Section
          _buildNFTInfoSection(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// Build header với icon và tên badge
  Widget _buildHeader(BuildContext context, Color rarityColor) {
    return Center(
      child: Column(
        children: [
          // Badge Icon
          Icon(Icons.workspace_premium, size: 100, color: rarityColor),
          const SizedBox(height: 12),

          // Badge Name
          Text(
            badge.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),

          // Rarity Label
          Text(
            badge.rarity.name.toUpperCase(),
            style: TextStyle(color: rarityColor),
          ),
        ],
      ),
    );
  }

  /// Build section hiển thị chi tiết workout
  Widget _buildWorkoutDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKey.workoutDetails.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(LocaleKey.type.tr, badge.metadata.workoutType),
        _buildDetailRow(
          LocaleKey.exercises.tr,
          '${badge.metadata.totalExercises}',
        ),
        _buildDetailRow(
          LocaleKey.duration.tr,
          '${badge.metadata.durationMinutes} min',
        ),
        _buildDetailRow(
          LocaleKey.calories.tr,
          '${badge.metadata.caloriesBurned.toInt()} kcal',
        ),
      ],
    );
  }

  /// Build section hiển thị thông tin NFT
  Widget _buildNFTInfoSection() {
    return Column(
      children: [
        _buildDetailRow(
          LocaleKey.minted.tr,
          BadgeRarityUtils.formatDate(badge.mintedAt),
        ),
        _buildDetailRow(LocaleKey.tokenId.tr, badge.tokenId),
      ],
    );
  }

  /// Build các action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Showcase/Unshowcase Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AchievementCubit>().toggleShowcase(badge.id);
              Navigator.pop(context);
            },
            icon: Icon(badge.isShowcased ? Icons.star : Icons.star_border),
            label: Text(
              badge.isShowcased
                  ? LocaleKey.removeShowcase.tr
                  : LocaleKey.showcase.tr,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Share & Post Buttons Row
        Row(
          children: [
            // External Share Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareBadgeExternal(badge),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  LocaleKey.share.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Post to Feed Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ShareToFeedDialog.show(context, badge);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor2,
                ),
                icon: const Icon(Icons.group, color: Colors.white),
                label: Text(
                  LocaleKey.post.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build một row hiển thị label và value
  ///
  /// [label] Nhãn bên trái
  /// [value] Giá trị bên phải
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Share badge ra external apps (WhatsApp, Telegram, etc.)
  Future<void> _shareBadgeExternal(NFTBadge badge) async {
    final shareText = BadgeRarityUtils.generateExternalShareText(badge);

    try {
      await Share.share(shareText, subject: '🏆 NFT Fitness Badge!');
    } catch (e) {
      print('❌ Share error: $e');
    }
  }
}
