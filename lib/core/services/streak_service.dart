import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';

class StreakService {
  final _supabase = Supabase.instance.client;

  // Singleton pattern
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  // ✅ Cache để tránh fetch liên tục
  StreakData? _cachedStreakData;
  String? _cachedUserId;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(seconds: 30); // Cache 30 giây

  /// Record workout and update streak
  Future<StreakResult> recordWorkout(
    String userId, {
    int? exercisesCompleted,
    int? durationMinutes,
    int? caloriesBurned,
  }) async {
    print('🔥 StreakService.recordWorkout called');
    print('   User ID: $userId');
    print('   Exercises: $exercisesCompleted');
    print('   Duration: $durationMinutes min');
    print('   Calories: $caloriesBurned');

    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    print('   Date: $dateOnly');

    // Kiểm tra đã workout hôm nay chưa
    print('🔍 Checking if already worked out today...');
    final existingHistory = await _supabase
        .from('streak_history')
        .select()
        .eq('for_user', userId)
        .eq('workout_date', dateOnly.toIso8601String().split('T')[0])
        .maybeSingle();

    print('   Existing history: ${existingHistory != null}');

    if (existingHistory != null) {
      print('⚠️ Already worked out today! Not recording again.');

      final streakData = await _supabase
          .from('workout_streaks')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      return StreakResult(
        success: false,
        currentStreak: streakData?['current_streak'] as int?,
        longestStreak: streakData?['longest_streak'] as int?,
        isNewRecord: false,
        nextMilestone: _getNextMilestone(
          streakData?['current_streak'] as int? ?? 0,
        ),
        achievedMilestone: null,
        message: 'Already worked out today!',
      );
    }

    // Get current streak data
    print('📊 Getting current streak data...');
    final streakData = await _supabase
        .from('workout_streaks')
        .select()
        .eq('for_user', userId)
        .maybeSingle();

    print('   Existing streak data: ${streakData != null}');

    int newStreak = 1;
    bool isNewRecord = false;

    if (streakData != null) {
      print('✅ Found existing streak data');
      final lastWorkout = DateTime.parse(streakData['last_workout_date']);
      final lastWorkoutDateOnly = DateTime(
        lastWorkout.year,
        lastWorkout.month,
        lastWorkout.day,
      );

      final daysDifference = dateOnly.difference(lastWorkoutDateOnly).inDays;
      print('   Last workout: $lastWorkoutDateOnly');
      print('   Days difference: $daysDifference');

      // Lấy streak_start_date hiện tại
      DateTime? currentStreakStartDate;
      if (streakData['streak_start_date'] != null) {
        currentStreakStartDate = DateTime.parse(
          streakData['streak_start_date'],
        );
      }

      if (daysDifference == 1) {
        newStreak = (streakData['current_streak'] as int) + 1;
        print('✅ Consecutive day! New streak: $newStreak');
        // Giữ nguyên streak_start_date
      } else if (daysDifference > 1) {
        newStreak = 1;
        print('❌ Missed day(s)! Streak reset to 1');
        // Reset streak_start_date thành hôm nay
        currentStreakStartDate = dateOnly;
      } else if (daysDifference == 0) {
        // Same day workout - không tăng streak
        newStreak = streakData['current_streak'] as int;
      }

      final previousLongest = streakData['longest_streak'] as int;
      isNewRecord = newStreak > previousLongest;
      print('   Previous longest: $previousLongest');
      print('   New record: $isNewRecord');

      print('💾 Updating streak in database...');
      await _supabase
          .from('workout_streaks')
          .update({
            'current_streak': newStreak,
            'longest_streak': isNewRecord ? newStreak : previousLongest,
            'last_workout_date': now.toIso8601String(),
            'streak_start_date': (currentStreakStartDate ?? dateOnly)
                .toIso8601String(),
            'total_workouts': (streakData['total_workouts'] as int) + 1,
          })
          .eq('for_user', userId);
      print('✅ Streak updated in database');
    } else {
      print('🆕 No existing streak data, creating new...');
      await _supabase.from('workout_streaks').insert({
        'for_user': userId,
        'current_streak': 1,
        'longest_streak': 1,
        'last_workout_date': now.toIso8601String(),
        'streak_start_date': dateOnly
            .toIso8601String(), // ✅ Thêm streak_start_date
        'total_workouts': 1,
      });
      print('✅ New streak record created');
      isNewRecord = true;
    }

    // Record history
    print('📝 Recording workout in history...');
    await _supabase.from('streak_history').insert({
      'for_user': userId,
      'workout_date': dateOnly.toIso8601String(),
      'streak_at_time': newStreak,
      'exercises_completed': exercisesCompleted ?? 0,
      'duration_minutes': durationMinutes ?? 0,
      'calories_burned': caloriesBurned ?? 0,
    });
    print('✅ Workout history recorded');

    // ✅ Check milestone & mint NFT
    StreakMilestone? achievedMilestone;
    if (_isStreakMilestone(newStreak)) {
      print('🎯 Milestone reached: $newStreak days');
      achievedMilestone = await _handleMilestone(userId, newStreak);
    }

    // ✅ Clear cache sau khi update
    print('🗑️ Clearing streak cache...');
    clearCache();

    print('✅ === STREAK RECORDING COMPLETE ===');
    print('   New Streak: $newStreak days');
    print('   Longest: ${isNewRecord ? newStreak : "unchanged"}');
    print('   Is New Record: $isNewRecord');

    return StreakResult(
      success: true,
      currentStreak: newStreak,
      longestStreak: isNewRecord
          ? newStreak
          : (streakData?['longest_streak'] as int? ?? newStreak),
      isNewRecord: isNewRecord,
      nextMilestone: _getNextMilestone(newStreak),
      achievedMilestone: achievedMilestone,
      message: isNewRecord ? '🎉 New personal record!' : null,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isStreakMilestone(int days) {
    return [7, 14, 30, 50, 100, 365].contains(days);
  }

  int _getNextMilestone(int current) {
    final milestones = [7, 14, 30, 50, 100, 365];
    return milestones.firstWhere((m) => m > current, orElse: () => 500);
  }

  String _getMilestoneName(int days) {
    switch (days) {
      case 7:
        return '7-Day Fire Streak 🔥';
      case 14:
        return '2-Week Warrior ⚡';
      case 30:
        return '30-Day Champion 💎';
      case 50:
        return '50-Day Legend 👑';
      case 100:
        return '100-Day Titan 🏆';
      case 365:
        return 'Year-Long Master 🌟';
      default:
        return '$days-Day Streak';
    }
  }

  BadgeRarity _getStreakRarity(int days) {
    if (days >= 365) return BadgeRarity.legendary;
    if (days >= 100) return BadgeRarity.epic;
    if (days >= 30) return BadgeRarity.rare;
    return BadgeRarity.common;
  }

  /// Handle milestone achievement & prepare NFT
  Future<StreakMilestone?> _handleMilestone(String userId, int days) async {
    try {
      print('🎯 Milestone reached: $days days');

      // Check if already recorded
      final existing = await _supabase
          .from('streak_milestones')
          .select()
          .eq('for_user', userId)
          .eq('milestone_days', days)
          .maybeSingle();

      if (existing != null) {
        print('⚠️ Milestone already recorded');
        return null;
      }

      // Record milestone
      final milestoneData = await _supabase
          .from('streak_milestones')
          .insert({
            'for_user': userId,
            'milestone_days': days,
            'nft_minted': false, // Ready for blockchain integration
          })
          .select()
          .single();

      // ✅ READY FOR BLOCKCHAIN: Mint NFT here
      // Example with real blockchain:
      // final nftService = BlockchainNFTService();
      // final tokenId = await nftService.mintStreakBadge(...);
      // await _supabase.from('streak_milestones')
      //     .update({'nft_token_id': tokenId, 'nft_minted': true})
      //     .eq('id', milestoneData['id']);

      // For now, save mock NFT to database
      await _supabase.from('nft_badges').insert({
        'for_user': userId,
        'name': _getMilestoneName(days),
        'description': 'Achieved $days consecutive workout days',
        'rarity': _getStreakRarity(days).toString().split('.').last,
        'image_url': 'https://api.dicebear.com/7.x/shapes/svg?seed=streak$days',
        'metadata': {'type': 'streak_milestone', 'streak_days': days},
      });

      return StreakMilestone(
        days: days,
        name: _getMilestoneName(days),
        rarity: _getStreakRarity(days),
        achievedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error handling milestone: $e');
      return null;
    }
  }

  /// Get current streak data for user
  Future<StreakData?> getStreakData(
    String userId, {
    bool forceRefresh = false,
  }) async {
    try {
      // ✅ Check cache first
      final now = DateTime.now();
      if (!forceRefresh &&
          _cachedUserId == userId &&
          _cachedStreakData != null &&
          _lastFetchTime != null &&
          now.difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedStreakData;
      }

      final data = await _supabase
          .from('workout_streaks')
          .select()
          .eq('for_user', userId)
          .maybeSingle();

      if (data == null) return null;

      // ✅ Update cache
      _cachedStreakData = StreakData(
        currentStreak: data['current_streak'] as int,
        longestStreak: data['longest_streak'] as int,
        lastWorkoutDate: DateTime.parse(data['last_workout_date']),
        totalWorkouts: data['total_workouts'] as int,
      );
      _cachedUserId = userId;
      _lastFetchTime = now;

      return _cachedStreakData;
    } catch (e) {
      print('❌ Error getting streak data: $e');
      return null;
    }
  }

  /// Clear cache (call this when streak updates)
  void clearCache() {
    _cachedStreakData = null;
    _cachedUserId = null;
    _lastFetchTime = null;
  }

  /// Check if user has worked out today
  Future<bool> hasWorkedOutToday(String userId) async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    final result = await _supabase
        .from('streak_history')
        .select()
        .eq('for_user', userId)
        .eq('workout_date', dateOnly.toIso8601String().split('T')[0])
        .maybeSingle();

    return result != null;
  }

  /// Get workout history for calendar view
  Future<List<DateTime>> getWorkoutDates(
    String userId, {
    int lastNDays = 90,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: lastNDays));

    final response = await _supabase
        .from('streak_history')
        .select('workout_date')
        .eq('for_user', userId)
        .gte('workout_date', startDate.toIso8601String().split('T')[0])
        .order('workout_date', ascending: false);

    return response
        .map((row) => DateTime.parse(row['workout_date'] as String))
        .toList();
  }
}

/// Result model for workout recording
class StreakResult {
  final bool success;
  final int? currentStreak;
  final int? longestStreak;
  final bool isNewRecord;
  final int? nextMilestone;
  final StreakMilestone? achievedMilestone;
  final String? message;

  StreakResult({
    required this.success,
    this.currentStreak,
    this.longestStreak,
    this.isNewRecord = false,
    this.nextMilestone,
    this.achievedMilestone,
    this.message,
  });
}

/// Data model for streak information
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastWorkoutDate;
  final int totalWorkouts;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
    required this.totalWorkouts,
  });

  /// Check if streak is in danger (after 8 PM, no workout today)
  bool get isInDanger {
    final now = DateTime.now();
    final lastWorkoutDay = DateTime(
      lastWorkoutDate.year,
      lastWorkoutDate.month,
      lastWorkoutDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    // Nếu last workout không phải hôm nay
    if (!_isSameDay(lastWorkoutDay, today)) {
      // Và đã qua 8 PM
      if (now.hour >= 20) {
        return true;
      }
    }
    return false;
  }

  /// Will break tomorrow if no workout today
  bool get willBreakTomorrow {
    final now = DateTime.now();
    final lastWorkoutDay = DateTime(
      lastWorkoutDate.year,
      lastWorkoutDate.month,
      lastWorkoutDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    return !_isSameDay(lastWorkoutDay, today);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Milestone achievement model
class StreakMilestone {
  final int days;
  final String name;
  final BadgeRarity rarity;
  final DateTime achievedAt;

  StreakMilestone({
    required this.days,
    required this.name,
    required this.rarity,
    required this.achievedAt,
  });
}
