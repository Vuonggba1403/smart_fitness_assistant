import 'package:smart_fitness_assistant/core/models/nft_badge.dart';

class AchievementState {
  final List<Achievement> achievements;
  final List<NFTBadge> badges;
  final bool isMinting;
  final NFTBadge? lastMintedBadge;
  final String? error;

  AchievementState({
    required this.achievements,
    required this.badges,
    required this.isMinting,
    this.lastMintedBadge,
    this.error,
  });

  factory AchievementState.initial() =>
      AchievementState(achievements: [], badges: [], isMinting: false);

  AchievementState copyWith({
    List<Achievement>? achievements,
    List<NFTBadge>? badges,
    bool? isMinting,
    NFTBadge? lastMintedBadge,
    String? error,
  }) => AchievementState(
    achievements: achievements ?? this.achievements,
    badges: badges ?? this.badges,
    isMinting: isMinting ?? this.isMinting,
    lastMintedBadge: lastMintedBadge ?? this.lastMintedBadge,
    error: error,
  );

  List<NFTBadge> get showcasedBadges =>
      badges.where((b) => b.isShowcased).toList();
}
