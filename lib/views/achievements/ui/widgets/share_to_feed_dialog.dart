import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/utils/badge_rarity_utils.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

/// Dialog để share badge lên social feed
///
/// Dialog này cho phép user:
/// - Xem preview của badge
/// - Chỉnh sửa caption trước khi post
/// - Post badge lên social feed
class ShareToFeedDialog extends StatefulWidget {
  /// Badge cần share
  final NFTBadge badge;

  const ShareToFeedDialog({Key? key, required this.badge}) : super(key: key);

  /// Static method để show dialog
  ///
  /// [context] BuildContext để show dialog
  /// [badge] Badge cần share
  static void show(BuildContext context, NFTBadge badge) {
    showDialog(
      context: context,
      builder: (_) => ShareToFeedDialog(badge: badge),
    );
  }

  @override
  State<ShareToFeedDialog> createState() => _ShareToFeedDialogState();
}

class _ShareToFeedDialogState extends State<ShareToFeedDialog> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với caption mặc định
    _captionController = TextEditingController(
      text: BadgeRarityUtils.generateBadgeCaption(widget.badge),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKey.shareToSocialFeed.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Preview
          _buildBadgePreview(),
          const SizedBox(height: 16),

          // Caption TextField
          _buildCaptionTextField(),
        ],
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKey.cancel.tr),
        ),

        // Post Button
        ElevatedButton(
          onPressed: _handlePostToFeed,
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.primaryColor1,
          ),
          child: Text(
            LocaleKey.postToFeed.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Build preview của badge
  Widget _buildBadgePreview() {
    final rarityColor = BadgeRarityUtils.getColor(widget.badge.rarity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rarityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarityColor, width: 2),
      ),
      child: Row(
        children: [
          // Badge Icon
          Icon(Icons.workspace_premium, size: 40, color: rarityColor),
          const SizedBox(width: 12),

          // Badge Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Name
                Text(
                  widget.badge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                // Rarity Label
                Text(
                  widget.badge.rarity.name.toUpperCase(),
                  style: TextStyle(color: rarityColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build text field cho caption
  Widget _buildCaptionTextField() {
    return TextField(
      controller: _captionController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: LocaleKey.addCaption.tr,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Xử lý khi user nhấn post
  Future<void> _handlePostToFeed() async {
    final caption = _captionController.text.trim();

    try {
      // Check if caption is empty, use default if so
      final finalCaption = caption.isEmpty
          ? BadgeRarityUtils.generateBadgeCaption(widget.badge)
          : caption;

      // Create post with badge metadata
      final success = await context.read<SocialFeedCubit>().createPost(
        caption: finalCaption,
        imageUrl: null, // Không có image, chỉ badge info
        taggedCategoryId: null,
        taggedCategoryName: widget.badge.metadata.workoutType,
      );

      // Close dialog
      if (mounted) {
        Navigator.pop(context);

        // Show success or error message
        if (success) {
          AppSnackBar.success(context, LocaleKey.postedToFeed.tr);
        } else {
          AppSnackBar.error(context, LocaleKey.failedToPost.tr);
        }
      }
    } catch (e) {
      print('❌ Error sharing to feed: $e');
      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.error(context, 'Error: ${e.toString()}');
      }
    }
  }
}
