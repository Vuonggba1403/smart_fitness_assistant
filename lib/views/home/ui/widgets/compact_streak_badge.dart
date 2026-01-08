import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/services/streak_service.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Compact streak badge hiển thị bên cạnh username (TikTok style)
class CompactStreakBadge extends StatefulWidget {
  const CompactStreakBadge({super.key});

  @override
  State<CompactStreakBadge> createState() => _CompactStreakBadgeState();
}

class _CompactStreakBadgeState extends State<CompactStreakBadge>
    with SingleTickerProviderStateMixin {
  final _streakService = StreakService();
  final _supabase = Supabase.instance.client;

  StreakData? _streakData;
  bool _loading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Không load ngay mà dùng cache
    _loadStreakData(forceRefresh: false);

    // Pulse animation for active streak
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadStreakData({bool forceRefresh = false}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Pass forceRefresh parameter
      final data = await _streakService.getStreakData(
        userId,
        forceRefresh: forceRefresh,
      );

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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final hasStreak = _streakData != null && _streakData!.currentStreak > 0;

    return GestureDetector(
      onTap: hasStreak ? _showStreakDetail : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: hasStreak
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasStreak ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: hasStreak
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire icon with pulse animation if active
            if (hasStreak)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 18,
                ),
              )
            else
              const Icon(
                Icons.local_fire_department_outlined,
                color: Colors.white70,
                size: 18,
              ),
            const SizedBox(width: 4),
            // Streak number
            Text(
              hasStreak ? '${_streakData!.currentStreak}' : '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                shadows: hasStreak
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDetail() {
    if (_streakData == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fire icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              // Current streak
              Text(
                '${_streakData!.currentStreak}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              Text(
                LocaleKey.daysStreak.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    '🏆',
                    '${_streakData!.longestStreak}',
                    LocaleKey.record.tr,
                  ),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildStat(
                    '💪',
                    '${_streakData!.totalWorkouts}',
                    LocaleKey.totalSessions.tr,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Refresh button
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _loadStreakData(forceRefresh: true);
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  LocaleKey.refresh.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
