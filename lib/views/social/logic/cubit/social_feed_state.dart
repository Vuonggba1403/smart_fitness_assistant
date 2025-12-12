part of 'social_feed_cubit.dart';

@immutable
sealed class SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<ContentPost> posts;
  SocialFeedLoaded(this.posts);
}

class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}
