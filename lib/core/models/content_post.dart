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
  final String? authorName;
  final String? categoryImageUrl;

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
  });

  factory ContentPost.fromJson(Map<String, dynamic> json) => ContentPost(
    id: json['id'] as String?,
    forUser: json['for_user'] as String?,
    caption: json['caption'] as String?,
    taggedCategoryId: json['tagged_category_id'] as String?,
    taggedCategoryName: json['tagged_category_name'] as String?,
    likesCount: json['likes_count'] as int?,
    commentsCount: json['comments_count'] as int?,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
    imageUrl: json['image_url'] as dynamic,
    authorName: json['author_name'] as String?,
    categoryImageUrl: json['category_image_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
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
  };

  @override
  List<Object?> get props {
    return [
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
    ];
  }
}
