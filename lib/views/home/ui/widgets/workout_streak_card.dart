import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/services/streak_service.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget hiển thị workout streak với fire animation
class WorkoutStreakCard extends StatefulWidget {
  final double width;

  const WorkoutStreakCard({super.key, required this.width});

  @override
  State<WorkoutStreakCard> createState() => _WorkoutStreakCardState();
}

class _WorkoutStreakCardState extends State<WorkoutStreakCard>
    with SingleTickerProviderStateMixin {
  final _streakService = StreakService();
  final _supabase = Supabase.instance.client;

  StreakData? _streakData;
  bool _loading = true;
  late AnimationController _fireAnimController;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();
    _loadStreakData();

    // Fire animation
    _fireAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fireAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _fireAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadStreakData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _streakService.getStreakData(userId);

      if (mounted) {
        setState(() {
          _streakData = data;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _fireAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return _buildLoadingCard(theme);
    }

    if (_streakData == null || _streakData!.currentStreak == 0) {
      return _buildEmptyStreakCard(theme);
    }

    return _buildStreakCard(theme, _streakData!);
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: widget.width,
      height: widget.width * 0.45,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(TColor.primaryG.first),
        ),
      ),
    );
  }

  Widget _buildEmptyStreakCard(ThemeData theme) {
    return Container(
      width: widget.width,
      height: widget.width * 0.45,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            size: 48,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKey.startYourStreak.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKey.completeFirstWorkout.tr,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme, StreakData data) {
    final nextMilestone = _getNextMilestone(data.currentStreak);
    final progress = data.currentStreak / nextMilestone;

    return Container(
      width: widget.width,
      height: widget.width * 0.45,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getStreakGradient(data.currentStreak),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _getStreakColor(data.currentStreak).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _fireAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _fireAnimation.value,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKey.dayStreak.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (data.isInDanger)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LocaleKey.danger.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Streak number
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.currentStreak}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKey.days.tr.toLowerCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Progress to next milestone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${nextMilestone - data.currentStreak} ${LocaleKey.daysTo.tr} ${_getMilestoneEmoji(nextMilestone)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    LocaleKey.record.tr + ': ${data.longestStreak} 🏆',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getStreakGradient(int days) {
    if (days >= 365)
      return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
    if (days >= 100)
      return [const Color(0xFF9C27B0), const Color(0xFF673AB7)]; // Purple
    if (days >= 50)
      return [const Color(0xFF3F51B5), const Color(0xFF2196F3)]; // Blue
    if (days >= 30)
      return [const Color(0xFFE91E63), const Color(0xFFF44336)]; // Pink-Red
    if (days >= 14)
      return [const Color(0xFFFF9800), const Color(0xFFFF5722)]; // Orange
    return [const Color(0xFFFF6B6B), const Color(0xFFFF5252)]; // Red
  }

  Color _getStreakColor(int days) {
    if (days >= 365) return const Color(0xFFFFD700);
    if (days >= 100) return const Color(0xFF9C27B0);
    if (days >= 50) return const Color(0xFF3F51B5);
    if (days >= 30) return const Color(0xFFE91E63);
    if (days >= 14) return const Color(0xFFFF9800);
    return const Color(0xFFFF6B6B);
  }

  int _getNextMilestone(int current) {
    final milestones = [7, 14, 30, 50, 100, 365];
    return milestones.firstWhere((m) => m > current, orElse: () => 500);
  }

  String _getMilestoneEmoji(int days) {
    if (days >= 365) return '🌟';
    if (days >= 100) return '🏆';
    if (days >= 50) return '👑';
    if (days >= 30) return '💎';
    if (days >= 14) return '⚡';
    return '🔥';
  }
}
