import 'package:equatable/equatable.dart';

/// ✅ Model cho bài đăng trên feed xã hội
class FeedPost extends Equatable {
  final String id;
  final String userId; // ✅ THÊM: Store user ID
  final String userName; // ✅ Thực tế username từ DB
  final String userAvatar;
  final String caption;
  final String imageUrl;
  final String? taggedCategory;
  final String? taggedCategoryId; // ✅ THÊM
  final String? categoryImageUrl; // ✅ THÊM - Ảnh của category
  final int likes;
  final int comments;
  final DateTime timestamp;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.caption,
    required this.imageUrl,
    this.taggedCategory,
    this.taggedCategoryId,
    this.categoryImageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userAvatar,
    caption,
    imageUrl,
    taggedCategory,
    taggedCategoryId,
    categoryImageUrl,
    likes,
    comments,
    timestamp,
  ];
}
