import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';

class NFTCollectionScreen extends StatelessWidget {
  const NFTCollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.nftBadgeCollection.tr),
      body: BlocBuilder<AchievementCubit, AchievementState>(
        builder: (context, state) {
          if (state.badges.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Summary
                _buildStatsCard(context, state),
                const SizedBox(height: 24),

                // Showcased Badges
                if (state.showcasedBadges.isNotEmpty) ...[
                  Text(
                    LocaleKey.showcased.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildBadgeGrid(context, state.showcasedBadges, state),
                  const SizedBox(height: 24),
                ],

                // All Badges
                Text(
                  '${LocaleKey.allBadges.tr} (${state.badges.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildBadgeGrid(context, state.badges, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKey.noBadgesYet.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKey.completeBadgesMessage.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AchievementState state) {
    final rarityCount = <BadgeRarity, int>{};
    for (var badge in state.badges) {
      rarityCount[badge.rarity] = (rarityCount[badge.rarity] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKey.collectionStats.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRarityCount(
                  LocaleKey.common.tr,
                  rarityCount[BadgeRarity.common] ?? 0,
                  Colors.grey,
                ),
                _buildRarityCount(
                  LocaleKey.rare.tr,
                  rarityCount[BadgeRarity.rare] ?? 0,
                  Colors.blue,
                ),
                _buildRarityCount(
                  LocaleKey.epic.tr,
                  rarityCount[BadgeRarity.epic] ?? 0,
                  Colors.purple,
                ),
                _buildRarityCount(
                  LocaleKey.legendary.tr,
                  rarityCount[BadgeRarity.legendary] ?? 0,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBadgeGrid(
    BuildContext context,
    List<NFTBadge> badges,
    AchievementState state,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(context, badge);
      },
    );
  }

  Widget _buildBadgeCard(BuildContext context, NFTBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Card(
        color: _getRarityColor(badge.rarity).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Icon
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 60,
                    color: _getRarityColor(badge.rarity),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Badge Name
              Text(
                badge.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRarityColor(badge.rarity),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),

              // Showcase Star
              if (badge.isShowcased)
                const Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, NFTBadge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Icon & Name
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 100,
                    color: _getRarityColor(badge.rarity),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    badge.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    badge.rarity.name.toUpperCase(),
                    style: TextStyle(color: _getRarityColor(badge.rarity)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metadata
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
            const Divider(),
            _buildDetailRow(LocaleKey.minted.tr, _formatDate(badge.mintedAt)),
            _buildDetailRow(LocaleKey.tokenId.tr, badge.tokenId),
            const SizedBox(height: 24),

            // Actions with Share
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AchievementCubit>().toggleShowcase(badge.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      badge.isShowcased ? Icons.star : Icons.star_border,
                    ),
                    label: Text(
                      badge.isShowcased
                          ? LocaleKey.removeShowcase.tr
                          : LocaleKey.showcase.tr,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareBadgeExternal(badge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                        ),
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: Text(
                          LocaleKey.share.tr,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showShareToFeedDialog(context, badge);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor2,
                        ),
                        icon: const Icon(Icons.group, color: Colors.white),
                        label: Text(
                          LocaleKey.post.tr,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareToFeedDialog(BuildContext context, NFTBadge badge) {
    final captionController = TextEditingController(
      text: _generateBadgeCaption(badge),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKey.shareToSocialFeed.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRarityColor(badge.rarity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRarityColor(badge.rarity),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 40,
                    color: _getRarityColor(badge.rarity),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          badge.rarity.name.toUpperCase(),
                          style: TextStyle(
                            color: _getRarityColor(badge.rarity),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Caption TextField
            TextField(
              controller: captionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: LocaleKey.addCaption.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              captionController.dispose();
              Navigator.pop(dialogContext);
            },
            child: Text(LocaleKey.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              await _shareToFeed(context, badge, captionController.text.trim());
              captionController.dispose();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primaryColor1,
            ),
            child: Text(
              LocaleKey.postToFeed.tr,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((_) {
      captionController.dispose();
    });
  }

  String _generateBadgeCaption(NFTBadge badge) {
    return '''
🏆 Just earned a ${badge.rarity.name.toUpperCase()} badge! 🏆

✅ ${badge.name}
💪 ${badge.metadata.workoutType}
🏋️ ${badge.metadata.totalExercises} exercises
⏱️ ${badge.metadata.durationMinutes} min
🔥 ${badge.metadata.caloriesBurned.toInt()} kcal

#NFTFitness #WorkoutBadge #${badge.rarity.name}Badge
''';
  }

  Future<void> _shareToFeed(
    BuildContext context,
    NFTBadge badge,
    String caption,
  ) async {
    try {
      // Check if caption is empty
      if (caption.isEmpty) {
        caption = _generateBadgeCaption(badge);
      }

      // Create post with badge metadata
      final success = await context.read<SocialFeedCubit>().createPost(
        caption: caption,
        imageUrl: null, // No image, just badge info
        taggedCategoryId: null,
        taggedCategoryName: badge.metadata.workoutType,
      );

      if (success && context.mounted) {
        AppSnackBar.success(context, LocaleKey.postedToFeed.tr);
      } else if (context.mounted) {
        AppSnackBar.error(context, LocaleKey.failedToPost.tr);
      }
    } catch (e) {
      print('❌ Error sharing to feed: $e');
      if (context.mounted) {
        AppSnackBar.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _shareBadgeExternal(NFTBadge badge) async {
    final shareText =
        '''
🏆 NFT Fitness Badge Earned! 🏆

🎖️ Badge: ${badge.name}
⭐ Rarity: ${badge.rarity.name.toUpperCase()}

💪 Workout: ${badge.metadata.workoutType}
🏋️ Exercises: ${badge.metadata.totalExercises}
⏱️ Duration: ${badge.metadata.durationMinutes} min
🔥 Calories: ${badge.metadata.caloriesBurned.toInt()} kcal

🔗 Token ID: ${badge.tokenId}
📅 Minted: ${_formatDate(badge.mintedAt)}

#FitnessApp #WorkoutBadge #AchievementUnlocked
''';

    try {
      await Share.share(shareText, subject: '🏆 NFT Fitness Badge!');
    } catch (e) {
      print('❌ Share error: $e');
    }
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }
}
