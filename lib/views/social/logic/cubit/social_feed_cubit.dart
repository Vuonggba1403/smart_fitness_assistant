import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';

part 'social_feed_state.dart';

class SocialFeedCubit extends Cubit<SocialFeedState> {
  final _supabase = Supabase.instance.client;

  SocialFeedCubit() : super(SocialFeedLoading());

  /// LOAD FEED
  Future<void> loadFeed() async {
    emit(SocialFeedLoading());
    try {
    final response = await _supabase
    .from('content_posts')
    .select('''
      *,
      user(*),
      exercise_categories!content_posts_tagged_category_id_fkey(*)
    ''')
    .order('created_at', ascending: false);


      emit(
        SocialFeedLoaded(
          posts: response.map((e) => ContentPost.fromJson(e)).toList(),
        ),
      );
    } catch (e) {
      emit(SocialFeedError('Không thể tải bài viết'));
    }
  }

  /// ✅ UPDATE SELECTED IMAGE
  void setSelectedImage(File? image) {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(currentState.copyWith(selectedImage: image));
    }
  }

  /// ✅ UPDATE SELECTED CATEGORY
  void setSelectedCategory(ExerciseCategory? category) {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  /// ✅ TOGGLE EMOJI PICKER
  void toggleEmojiPicker() {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(currentState.copyWith(
        showEmojiPicker: !currentState.showEmojiPicker,
      ));
    }
  }

  /// ✅ SET EMOJI PICKER
  void setShowEmojiPicker(bool value) {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(currentState.copyWith(showEmojiPicker: value));
    }
  }

  /// TẠO BÀI VIẾT
  Future<bool> createPost({
    required String caption,
    String? imageUrl,
    String? taggedCategoryId,
    String? taggedCategoryName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('content_posts').insert({
        'for_user': userId,
        'caption': caption,
        'image_url': imageUrl,
        'tagged_category_id': taggedCategoryId,
        'tagged_category_name': taggedCategoryName,
      });

      await loadFeed();
      // ✅ Reset UI state after successful post
      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        emit(currentState.resetUIState());
      }
      return true;
    } catch (e) {
      print('❌ Error creating post: $e');
      return false;
    }
  }

  /// LIKE / UNLIKE
  Future<void> togglePostLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final existing = await _supabase
          .from('post_favorites')
          .select()
          .eq('for_post', postId)
          .eq('from_user', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('post_favorites')
            .delete()
            .eq('for_post', postId)
            .eq('from_user', userId);
        await _supabase.rpc('decrement_likes', params: {'post_id': postId});
      } else {
        await _supabase.from('post_favorites').insert({
          'for_post': postId,
          'from_user': userId,
        });
        await _supabase.rpc('increment_likes', params: {'post_id': postId});
      }

      await loadFeed();
    } catch (e) {
      print('❌ Error like: $e');
    }
  }

  /// COMMENT
  Future<bool> addComment(String postId, String content) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('post_comments').insert({
        'for_post': postId,
        'from_user': userId,
        'content': content,
      });

      await _supabase.rpc('increment_comments', params: {'post_id': postId});
      await loadFeed();
      return true;
    } catch (e) {
      print('❌ Error comment: $e');
      return false;
    }
  }
}
