import 'package:equatable/equatable.dart';

class ContentPost extends Equatable {
  final String id;
  final String forUser;
  final String caption;
  final String? imageUrl;
  final String? taggedCategoryId;
  final String? taggedCategoryName;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLikedByMe; // ✅ Thêm flag để check đã like chưa
  final String? authorName; // ✅ Tên tác giả
  final String? authorAvatar; // ✅ Avatar tác giả

  const ContentPost({
    required this.id,
    required this.forUser,
    required this.caption,
    this.imageUrl,
    this.taggedCategoryId,
    this.taggedCategoryName,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isLikedByMe = false,
    this.authorName,
    this.authorAvatar,
  });

  factory ContentPost.fromJson(Map<String, dynamic> json) {
    return ContentPost(
      id: json['id'] ?? '',
      forUser: json['for_user'] ?? '',
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'],
      taggedCategoryId: json['tagged_category_id'],
      taggedCategoryName: json['tagged_category_name'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isLikedByMe: json['is_liked_by_me'] ?? false,
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'for_user': forUser,
    'caption': caption,
    'image_url': imageUrl,
    'tagged_category_id': taggedCategoryId,
    'tagged_category_name': taggedCategoryName,
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id, forUser, caption, imageUrl, taggedCategoryId,
    taggedCategoryName, likesCount, commentsCount, createdAt, updatedAt,
    isLikedByMe, authorName, authorAvatar,
  ];
}

class PostComment extends Equatable {
  final String id;
  final String forPost;
  final String fromUser;
  final String content;
  final DateTime createdAt;
  final String? userName; // ✅ Tên user
  final String? userAvatar; // ✅ Avatar user

  const PostComment({
    required this.id,
    required this.forPost,
    required this.fromUser,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      forPost: json['for_post'] ?? '',
      fromUser: json['from_user'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'for_post': forPost,
    'from_user': fromUser,
    'content': content,
  };

  @override
  List<Object?> get props => [id, forPost, fromUser, content, createdAt, userName, userAvatar];
}
