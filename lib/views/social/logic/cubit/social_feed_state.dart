part of 'social_feed_cubit.dart';

@immutable
sealed class SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<ContentPost> posts;
  final File? selectedImage;
  final ExerciseCategory? selectedCategory;
  final List<Map<String, dynamic>>? comments;

  SocialFeedLoaded({
    required this.posts,
    this.selectedImage,
    this.selectedCategory,
    this.comments,
  });

  // ✅ Copy state with new values
  SocialFeedLoaded copyWith({
    List<ContentPost>? posts,
    File? selectedImage,
    ExerciseCategory? selectedCategory,
    List<Map<String, dynamic>>? comments,
    bool clearImage = false,
  }) {
    return SocialFeedLoaded(
      posts: posts ?? this.posts,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      comments: comments ?? this.comments,
    );
  }

  // ✅ Reset UI state for new post
  SocialFeedLoaded resetUIState() {
    return SocialFeedLoaded(
      posts: posts,
      selectedImage: null,
      selectedCategory: null,
      comments: comments,
    );
  }
}

class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}

const _sentinel = Object();
