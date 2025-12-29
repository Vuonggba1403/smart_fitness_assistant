import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/nft_collection_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart'; // ✅ ADD

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

  // ✅ ADD: Static method show
  static Future<void> show(BuildContext context, SessionActive state) async {
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

  // 📌 4. MINT NFT BADGE - Core functionality
  Future<void> _mintBadge() async {
    setState(() => _isMinting = true); // Hiển thị loading

    // Gọi AchievementCubit để mint badge lên blockchain
    final badge = await context.read<AchievementCubit>().mintWorkoutBadge(
      workoutType: widget.workoutType, // VD: "Full Body Workout"
      totalExercises: widget.totalExercises, // VD: 12 exercises
      durationMinutes: widget.durationMinutes, // VD: 45 minutes
      caloriesBurned: widget.caloriesBurned, // VD: 350 kcal
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🏆 Trophy Icon
                  const Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: Colors.amber,
                  ),

                  // 🎉 Congratulations Text
                  Text(
                    '🎉 Congratulations! 🎉',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

                  const Spacer(),

                  // ✅ FIX: Action Buttons với Share
                  _buildActionButtons(context),
                ],
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
            _buildStatRow('Workout Type', widget.workoutType), // "Full Body"
            _buildStatRow('Exercises', '${widget.totalExercises}'), // "12"
            _buildStatRow(
              'Duration',
              '${widget.durationMinutes} min',
            ), // "45 min"
            _buildStatRow(
              'Calories',
              '${widget.caloriesBurned.toInt()} kcal',
            ), // "350 kcal"
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
          'Minting your NFT Badge...',
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
            const Icon(Icons.workspace_premium, size: 80, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              _mintedBadge!.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _mintedBadge!.rarity.name.toUpperCase(),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              'Token ID: ${_mintedBadge!.tokenId}',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
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
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(
                LocaleKey.shareAchievement.tr,
                style: TextStyle(
                  color: Colors.white,
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
              icon: const Icon(Icons.group, color: Colors.white),
              label: const Text(
                'Post to Social Feed',
                style: TextStyle(
                  color: Colors.white,
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
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
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
        AppSnackBar.success(context, '🎉 Posted to social feed!');
      } else if (mounted) {
        AppSnackBar.error(context, 'Failed to post');
      }
    } catch (e) {
      print('❌ Share to feed error: $e');
      if (mounted) {
        AppSnackBar.error(context, 'Error posting to feed');
      }
    }
  }
}
