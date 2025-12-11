import 'package:equatable/equatable.dart';

/// ✅ Model cho FeedPost
class FeedPost extends Equatable {
  final String id;
  final String userName;
  final String userAvatar;
  final String caption;
  final String imageUrl;
  final String? taggedCategory;
  final int likes;
  final int comments;
  final DateTime timestamp;

  const FeedPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.caption,
    required this.imageUrl,
    this.taggedCategory,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    userAvatar,
    caption,
    imageUrl,
    taggedCategory,
    likes,
    comments,
    timestamp,
  ];
}
