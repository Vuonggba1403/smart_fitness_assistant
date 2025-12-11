import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';

part 'social_feed_state.dart';

class SocialFeedCubit extends Cubit<SocialFeedState> {
  final _supabase = Supabase.instance.client;

  SocialFeedCubit() : super(SocialFeedInitial());

  /// ✅ Tạo post mới
  Future<bool> createPost({
    required String caption,
    String? imageUrl,
    String? taggedCategoryId,
    String? taggedCategoryName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('content_posts')
          .insert({
            'for_user': userId,
            'caption': caption,
            'image_url': imageUrl,
            'tagged_category_id': taggedCategoryId,
            'tagged_category_name': taggedCategoryName,
          })
          .select();

      print('✅ Post created: $response');
      return true;
    } catch (e) {
      print('❌ Error creating post: $e');
      return false;
    }
  }

  /// ✅ Load feed posts
  Future<List<ContentPost>> loadFeedPosts() async {
    try {
      final response = await _supabase
          .from('content_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      return response
          .map((json) => ContentPost.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error loading posts: $e');
      return [];
    }
  }

  /// ✅ Like/Unlike post
  Future<void> togglePostLike(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Check xem đã like chưa
      final existing = await _supabase
          .from('post_favorites')
          .select()
          .eq('for_post', postId)
          .eq('from_user', userId)
          .maybeSingle();

      if (existing != null) {
        // ✅ Unlike
        await _supabase
            .from('post_favorites')
            .delete()
            .eq('for_post', postId)
            .eq('from_user', userId);

        // ✅ Giảm likes_count
        await _supabase.rpc('decrement_likes', params: {'post_id': postId});
      } else {
        // ✅ Like
        await _supabase.from('post_favorites').insert({
          'for_post': postId,
          'from_user': userId,
        });

        // ✅ Tăng likes_count
        await _supabase.rpc('increment_likes', params: {'post_id': postId});
      }
    } catch (e) {
      print('❌ Error toggling like: $e');
    }
  }

  /// ✅ Comment trên post
  Future<bool> addComment(String postId, String content) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('post_comments').insert({
        'for_post': postId,
        'from_user': userId,
        'content': content,
      });

      // ✅ Tăng comments_count
      await _supabase.rpc('increment_comments', params: {'post_id': postId});

      return true;
    } catch (e) {
      print('❌ Error adding comment: $e');
      return false;
    }
  }

  /// ✅ Load comments cho post
  Future<List<PostComment>> loadPostComments(String postId) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .select()
          .eq('for_post', postId)
          .order('created_at', ascending: false);

      return response
          .map((json) => PostComment.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error loading comments: $e');
      return [];
    }
  }
}
