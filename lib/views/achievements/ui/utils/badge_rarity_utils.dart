import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/nft_badge.dart';

/// Utility class để xử lý các thao tác liên quan đến badge rarity
///
/// Class này cung cấp các helper methods như:
/// - Lấy màu sắc theo rarity level
/// - Format date
/// - Generate caption cho sharing
class BadgeRarityUtils {
  /// Lấy màu sắc đại diện cho từng rarity level
  ///
  /// - Common: Grey (Xám)
  /// - Rare: Blue (Xanh dương)
  /// - Epic: Purple (Tím)
  /// - Legendary: Amber (Vàng)
  static Color getColor(BadgeRarity rarity) {
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

  /// Format ngày tháng theo định dạng DD/MM/YYYY
  ///
  /// [date] Ngày cần format
  /// Returns: String theo format "DD/MM/YYYY"
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Tạo caption mặc định cho việc share badge
  ///
  /// Caption bao gồm:
  /// - Emoji và thông báo
  /// - Thông tin badge (tên, rarity)
  /// - Chi tiết workout (type, exercises, duration, calories)
  /// - Hashtags
  static String generateBadgeCaption(NFTBadge badge) {
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

  /// Tạo nội dung text cho external sharing (WhatsApp, Telegram, etc.)
  ///
  /// Format chi tiết hơn, bao gồm cả Token ID và ngày mint
  static String generateExternalShareText(NFTBadge badge) {
    return '''
🏆 NFT Fitness Badge Earned! 🏆

🎖️ Badge: ${badge.name}
⭐ Rarity: ${badge.rarity.name.toUpperCase()}

💪 Workout: ${badge.metadata.workoutType}
🏋️ Exercises: ${badge.metadata.totalExercises}
⏱️ Duration: ${badge.metadata.durationMinutes} min
🔥 Calories: ${badge.metadata.caloriesBurned.toInt()} kcal

🔗 Token ID: ${badge.tokenId}
📅 Minted: ${formatDate(badge.mintedAt)}

#FitnessApp #WorkoutBadge #AchievementUnlocked
''';
  }
}
