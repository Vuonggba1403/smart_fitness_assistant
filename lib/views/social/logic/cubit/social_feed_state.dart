part of 'social_feed_cubit.dart';

@immutable
sealed class SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<ContentPost> posts;
  final File? selectedImage;
  final ExerciseCategory? selectedCategory;
  final bool showEmojiPicker;

  SocialFeedLoaded({
    required this.posts,
    this.selectedImage,
    this.selectedCategory,
    this.showEmojiPicker = false,
  });

  // ✅ Copy state with new values
  SocialFeedLoaded copyWith({
    List<ContentPost>? posts,
    File? selectedImage,
    ExerciseCategory? selectedCategory,
    bool? showEmojiPicker,
    bool clearImage = false,
  }) {
    return SocialFeedLoaded(
      posts: posts ?? this.posts,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
    );
  }

  // ✅ Reset UI state for new post
  SocialFeedLoaded resetUIState() {
    return SocialFeedLoaded(
      posts: posts,
      selectedImage: null,
      selectedCategory: null,
      showEmojiPicker: false,
    );
  }
}

class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}

const _sentinel = Object();
