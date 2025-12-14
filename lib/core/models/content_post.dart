import 'package:equatable/equatable.dart';

class ContentPost extends Equatable {
  final String? id;
  final String? forUser;
  final String? caption;
  final String? taggedCategoryId;
  final String? taggedCategoryName;
  final int? likesCount;
  final int? commentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic imageUrl;

  /// User info (JOIN từ user)
  final String? authorName;

  /// Category image lấy từ exercise_categories.img_url
  final String? categoryImageUrl;

  /// Track if current user has liked this post
  final bool isLikedByMe;

  const ContentPost({
    this.id,
    this.forUser,
    this.caption,
    this.taggedCategoryId,
    this.taggedCategoryName,
    this.likesCount,
    this.commentsCount,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.authorName,
    this.categoryImageUrl,
    this.isLikedByMe = false,
  });

  factory ContentPost.fromJson(Map<String, dynamic> json) {
    return ContentPost(
      id: json['id'] as String?,
      forUser: json['for_user'] as String?,
      caption: json['caption'] as String?,
      taggedCategoryId: json['tagged_category_id'] as String?,
      taggedCategoryName: json['tagged_category_name'] as String?,
      likesCount: json['likes_count'] as int?,
      commentsCount: json['comments_count'] as int?,

      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,

      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,

      imageUrl: json["image_url"],

      /// 🔥 Lấy username từ user(*)
      authorName: json["user"]?["username"],

      /// 🔥 LẤY ẢNH CATEGORY TỪ exercise_categories.img_url
      categoryImageUrl: json["exercise_categories"]?["img_url"],

      /// 🔥 Check if current user has liked this post
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'for_user': forUser,
      'caption': caption,
      'tagged_category_id': taggedCategoryId,
      'tagged_category_name': taggedCategoryName,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image_url': imageUrl,
      'author_name': authorName,
      'category_image_url': categoryImageUrl,
      'is_liked_by_me': isLikedByMe,
    };
  }

  @override
  List<Object?> get props => [
        id,
        forUser,
        caption,
        taggedCategoryId,
        taggedCategoryName,
        likesCount,
        commentsCount,
        createdAt,
        updatedAt,
        imageUrl,
        authorName,
        categoryImageUrl,
        isLikedByMe,
      ];
}
