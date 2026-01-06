import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/nft_collection_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart';
import 'package:smart_fitness_assistant/views/auth/main_tab/ui/main_tab_view.dart'; // ✅ ADD

// 📌 1. PARAMETERS - Nhận data từ workout vừa hoàn thành
class WorkoutCongratulationsScreen extends StatefulWidget {
  final String workoutType; // Loại workout (Full Body, Cardio, Strength...)
  final int totalExercises; // Tổng số bài tập đã làm
  final int durationMinutes; // Thời gian tập (phút)
  final double caloriesBurned; // Calories tiêu thụ

  const WorkoutCongratulationsScreen({
    Key? key,
    required this.workoutType,
    required this.totalExercises,
    required this.durationMinutes,
    required this.caloriesBurned,
  }) : super(key: key);

  // ✅ ADD: Static method show with safe navigation
  static Future<void> show(BuildContext context, SessionActive state) async {
    if (!context.mounted) return;

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutCongratulationsScreen(
            workoutType: state.categoryName,
            totalExercises: state.exercises.length,
            durationMinutes: state.elapsedSeconds ~/ 60,
            caloriesBurned: state.exercises.length * 50.0,
          ),
        ),
      );
    } catch (e) {
      print('Error showing congratulations screen: $e');
    }
  }

  @override
  State<WorkoutCongratulationsScreen> createState() =>
      _WorkoutCongratulationsScreenState();
}

// 📌 2. STATE VARIABLES
class _WorkoutCongratulationsScreenState
    extends State<WorkoutCongratulationsScreen> {
  // Controller cho confetti animation (pháo giấy 🎉)
  late ConfettiController _confettiController;

  // Tracking trạng thái minting NFT
  bool _isMinting = false;

  // Store NFT badge sau khi mint xong
  NFTBadge? _mintedBadge;

  @override
  void initState() {
    super.initState();

    // Tạo confetti controller (pháo giấy tự bay trong 3 giây)
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Bắn confetti ngay lập tức 🎊
    _confettiController.play();

    // Bắt đầu mint NFT badge tự động
    _mintBadge();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Mints a new achievement badge for completed workout
  Future<void> _mintBadge() async {
    setState(() => _isMinting = true);

    final badge = await context.read<AchievementCubit>().mintWorkoutBadge(
      workoutType: widget.workoutType,
      totalExercises: widget.totalExercises,
      durationMinutes: widget.durationMinutes,
      caloriesBurned: widget.caloriesBurned,
    );

    if (mounted) {
      setState(() {
        _isMinting = false; // Tắt loading
        _mintedBadge = badge; // Lưu badge vừa mint
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========== CONFETTI ANIMATION ==========
          // Pháo giấy bay từ trên xuống
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // Nổ tung tóe 💥
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),

          // ========== MAIN CONTENT ==========
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // 🏆 Trophy Icon
                    const Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: Colors.amber,
                    ),

                    // 🎉 Congratulations Text
                    Text(
                      LocaleKey.congratulations.tr,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 📊 Workout Stats Card (exercises, duration, calories)
                    _buildStatCard(context),
                    const SizedBox(height: 32),

                    // 🏅 NFT Minting Section
                    if (_isMinting)
                      _buildMintingProgress()
                    else if (_mintedBadge != null)
                      _buildMintedBadge()
                    else
                      const SizedBox.shrink(),

                    // Thay Spacer bằng SizedBox với height cố định
                    const SizedBox(height: 32),

                    // ✅ FIX: Action Buttons với Share
                    _buildActionButtons(context),

                    // Padding bottom để tránh button bị che bởi keyboard/nav bar
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 6. STAT CARD - Hiển thị thông số workout
  Widget _buildStatCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow(
              LocaleKey.workoutType.tr,
              widget.workoutType,
            ), // "Full Body"
            _buildStatRow(
              LocaleKey.exercises.tr,
              '${widget.totalExercises}',
            ), // "12"
            _buildStatRow(
              LocaleKey.duration.tr,
              '${widget.durationMinutes} ${LocaleKey.minutes.tr}',
            ),
            _buildStatRow(
              LocaleKey.calories.tr,
              '${widget.caloriesBurned.toInt()} ${LocaleKey.kcal.tr}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 📌 7. MINTING PROGRESS - Loading state
  Widget _buildMintingProgress() {
    return Column(
      children: [
        const CircularProgressIndicator(), // ⏳ Spinner
        const SizedBox(height: 16),
        Text(
          LocaleKey.minting.tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKey.pleaseWait.tr,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // 📌 8. MINTED BADGE - Hiển thị badge sau khi mint xong
  Widget _buildMintedBadge() {
    return Card(
      color: _getRarityColor(_mintedBadge!.rarity), // Màu theo độ hiếm
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.workspace_premium, size: 80, color: TColor.white),
            const SizedBox(height: 12),
            Text(
              _mintedBadge!.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColor.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _mintedBadge!.rarity.name.toUpperCase(),
              style: TextStyle(color: TColor.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            Text(
              'Token ID: ${_mintedBadge!.tokenId}',
              style: TextStyle(
                fontSize: 12,
                color: TColor.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 9. RARITY COLOR - Màu sắc theo độ hiếm
  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey; // ⚪ Xám - Thường
      case BadgeRarity.rare:
        return Colors.blue; // 🔵 Xanh - Hiếm
      case BadgeRarity.epic:
        return Colors.purple; // 🟣 Tím - Sử thi
      case BadgeRarity.legendary:
        return Colors.amber; // 🟡 Vàng - Huyền thoại
    }
  }

  // ✅ NEW: Build Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // ✅ Share Button (nếu đã mint badge)
        if (_mintedBadge != null) ...[
          // Share to External Apps
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareAchievement(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(Icons.share, color: TColor.white),
              label: Text(
                LocaleKey.shareAchievement.tr,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ NEW: Share to Social Feed
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareToFeed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor2,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(Icons.group, color: TColor.white),
              label: Text(
                LocaleKey.postToFeed.tr,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Row buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NFTCollectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(LocaleKey.viewCollection.tr),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => navigateTo(context, MainTabView()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(LocaleKey.home.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ NEW: Share Achievement Function
  Future<void> _shareAchievement() async {
    if (_mintedBadge == null) return;

    final shareText =
        '''
🎉 Workout Achievement Unlocked! 🎉

💪 ${widget.workoutType}
🏋️ Exercises: ${widget.totalExercises}
⏱️ Duration: ${widget.durationMinutes} min
🔥 Calories: ${widget.caloriesBurned.toInt()} kcal

🏆 NFT Badge: ${_mintedBadge!.name}
⭐ Rarity: ${_mintedBadge!.rarity.name.toUpperCase()}
🔗 Token ID: ${_mintedBadge!.tokenId}

#FitnessGoals #NFTBadge #WorkoutComplete
''';

    try {
      await Share.share(shareText, subject: '🏆 Workout Achievement!');
    } catch (e) {
      print('❌ Share error: $e');
    }
  }

  // ✅ NEW: Share to Social Feed
  Future<void> _shareToFeed() async {
    if (_mintedBadge == null) return;

    try {
      final caption =
          '''
🎉 Just completed a workout! 🎉

💪 ${widget.workoutType}
🏋️ Exercises: ${widget.totalExercises}
⏱️ Duration: ${widget.durationMinutes} min
🔥 Calories: ${widget.caloriesBurned.toInt()} kcal

🏆 Earned: ${_mintedBadge!.name}
⭐ Rarity: ${_mintedBadge!.rarity.name.toUpperCase()}
🔗 Token ID: ${_mintedBadge!.tokenId}

#FitnessGoals #NFTBadge #WorkoutComplete
''';

      final success = await context.read<SocialFeedCubit>().createPost(
        caption: caption,
        imageUrl: null,
        taggedCategoryId: null,
        taggedCategoryName: widget.workoutType,
      );

      if (success && mounted) {
        AppSnackBar.success(context, LocaleKey.postedToFeed.tr);
      } else if (mounted) {
        AppSnackBar.error(context, LocaleKey.failedToPost.tr);
      }
    } catch (e) {
      print('❌ Share to feed error: $e');
      if (mounted) {
        AppSnackBar.error(context, LocaleKey.errorLoadData.tr);
      }
    }
  }
}
