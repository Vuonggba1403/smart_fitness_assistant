import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/day_plan_progress.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/achievements/logic/cubit/achievement_cubit.dart';
import 'package:smart_fitness_assistant/views/achievements/ui/nft_collection_screen.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:confetti/confetti.dart';

/// Màn hình congratulations sau khi hoàn thành 30-day workout plan
class WorkoutPlanCompletionScreen extends StatefulWidget {
  final WorkoutPlanProgress progress;

  const WorkoutPlanCompletionScreen({super.key, required this.progress});

  @override
  State<WorkoutPlanCompletionScreen> createState() =>
      _WorkoutPlanCompletionScreenState();
}

class _WorkoutPlanCompletionScreenState
    extends State<WorkoutPlanCompletionScreen> {
  late ConfettiController _confettiController;
  bool _isMintingBadge = false;
  bool _badgeMinted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    // Auto-mint badge sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _mintCompletionBadge();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Mint NFT badge khi hoàn thành 30-day plan
  Future<void> _mintCompletionBadge() async {
    if (_isMintingBadge || _badgeMinted) return;

    setState(() => _isMintingBadge = true);

    try {
      final achievementCubit = context.read<AchievementCubit>();

      // Tính tổng thời gian và exercises
      int totalDurationMinutes = 0;
      int totalExercises = 0;

      for (var dayProgress in widget.progress.dayProgressList) {
        if (dayProgress.workoutDurationSeconds != null) {
          totalDurationMinutes += (dayProgress.workoutDurationSeconds! / 60)
              .round();
        }
        totalExercises += dayProgress.completedExercises;
      }

      // Calculate calories (ước tính 5 cal/phút)
      final caloriesBurned = totalDurationMinutes * 5.0;

      // Mint badge
      final badge = await achievementCubit.mintWorkoutBadge(
        workoutType: '30-Day Workout Plan',
        totalExercises: totalExercises,
        durationMinutes: totalDurationMinutes,
        caloriesBurned: caloriesBurned,
      );

      if (badge != null && mounted) {
        setState(() {
          _badgeMinted = true;
          _isMintingBadge = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKey.badgeMinted.tr),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error minting badge: $e');
      if (mounted) {
        setState(() => _isMintingBadge = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = widget.progress.completedDaysCount;
    final startDate = widget.progress.startedAt;
    final endDate = widget.progress.completedAt ?? DateTime.now();
    final duration = endDate.difference(startDate).inDays + 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [TColor.primaryColor1, TColor.primaryColor2],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Trophy icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Congratulations text
                    Text(
                      LocaleKey.congratulations.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      LocaleKey.completedSevenDayPlan.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Stats cards
                    _buildStatsCard(totalDays, duration),

                    const SizedBox(height: 32),

                    // Badge minting status
                    if (_isMintingBadge)
                      _buildMintingCard()
                    else if (_badgeMinted)
                      _buildBadgeMintedCard(),

                    const SizedBox(height: 32),

                    // Action buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int totalDays, int duration) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            LocaleKey.yourAchievement.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColor.primaryColor1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.calendar_today,
                '$totalDays',
                LocaleKey.daysCompleted.tr,
              ),
              Container(
                width: 1,
                height: 50,
                color: TColor.gray.withOpacity(0.3),
              ),
              _buildStatItem(Icons.timer, '$duration', LocaleKey.totalDays.tr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: TColor.primaryColor1, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: TColor.primaryColor1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: TColor.secondaryColor1),
        ),
      ],
    );
  }

  Widget _buildMintingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            LocaleKey.mintingBadge.tr,
            style: TextStyle(fontSize: 14, color: TColor.secondaryColor1),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeMintedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LocaleKey.badgeMintedSuccess.tr,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // View badges button
        if (_badgeMinted)
          ElevatedButton.icon(
            onPressed: () {
              navigateTo(context, const NFTCollectionScreen());
            },
            icon: const Icon(Icons.stars),
            label: Text(LocaleKey.viewBadges.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: TColor.primaryColor1,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Close button
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(LocaleKey.close.tr),
        ),
      ],
    );
  }
}
