part of 'social_feed_cubit.dart';

@immutable
sealed class SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<ContentPost> posts;
  final File? selectedImage;
  final ExerciseCategory? selectedCategory;
  final List<Map<String, dynamic>>? comments;
  final bool hasMore;
  final bool isLoadingMore;

  SocialFeedLoaded({
    required this.posts,
    this.selectedImage,
    this.selectedCategory,
    this.comments,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  // ✅ Copy state with new values
  SocialFeedLoaded copyWith({
    List<ContentPost>? posts,
    File? selectedImage,
    ExerciseCategory? selectedCategory,
    List<Map<String, dynamic>>? comments,
    bool clearImage = false,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SocialFeedLoaded(
      posts: posts ?? this.posts,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  // ✅ Reset UI state for new post
  SocialFeedLoaded resetUIState() {
    return SocialFeedLoaded(
      posts: posts,
      selectedImage: null,
      selectedCategory: null,
      comments: comments,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    );
  }
}

class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}
