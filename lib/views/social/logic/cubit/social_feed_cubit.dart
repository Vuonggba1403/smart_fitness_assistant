import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

part 'social_feed_state.dart';

class SocialFeedCubit extends Cubit<SocialFeedState> {
  final _supabase = Supabase.instance.client;
  static const int _pageSize = 15;

  SocialFeedCubit() : super(SocialFeedLoading());

  /// LOAD FEED (initial load)
  Future<void> loadFeed() async {
    emit(SocialFeedLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('content_posts')
          .select('''
            *,
            user(*),
            exercise_categories!content_posts_tagged_category_id_fkey(*)
          ''')
          .order('created_at', ascending: false)
          .limit(_pageSize);

      // 🔥 Check if current user has liked each post
      List<ContentPost> posts = response.map((e) {
        final post = ContentPost.fromJson(e);
        return post;
      }).toList();

      // 🔥 If user is logged in, check likes for each post
      if (userId != null) {
        final likedPostIds = await _getLikedPostIds(userId);
        posts = posts.map((post) {
          if (post.id != null && likedPostIds.contains(post.id)) {
            // Create a new post with isLikedByMe = true
            return ContentPost(
              id: post.id,
              forUser: post.forUser,
              caption: post.caption,
              taggedCategoryId: post.taggedCategoryId,
              taggedCategoryName: post.taggedCategoryName,
              likesCount: post.likesCount,
              commentsCount: post.commentsCount,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              imageUrl: post.imageUrl,
              authorName: post.authorName,
              categoryImageUrl: post.categoryImageUrl,
              isLikedByMe: true,
            );
          }
          return post;
        }).toList();
      }

      emit(SocialFeedLoaded(posts: posts, hasMore: posts.length >= _pageSize));
    } catch (e) {
      print('❌ Error loading feed: $e');
      emit(SocialFeedError(LocaleKey.errorLoadPosts.tr));
    }
  }

  /// LOAD MORE POSTS (pagination)
  Future<void> loadMorePosts() async {
    if (state is! SocialFeedLoaded) return;

    final currentState = state as SocialFeedLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final userId = _supabase.auth.currentUser?.id;
      final currentPosts = currentState.posts;

      final response = await _supabase
          .from('content_posts')
          .select('''
            *,
            user(*),
            exercise_categories!content_posts_tagged_category_id_fkey(*)
          ''')
          .order('created_at', ascending: false)
          .range(currentPosts.length, currentPosts.length + _pageSize - 1);

      List<ContentPost> newPosts = response.map((e) {
        final post = ContentPost.fromJson(e);
        return post;
      }).toList();

      // Check likes for new posts
      if (userId != null && newPosts.isNotEmpty) {
        final likedPostIds = await _getLikedPostIds(userId);
        newPosts = newPosts.map((post) {
          if (post.id != null && likedPostIds.contains(post.id)) {
            return ContentPost(
              id: post.id,
              forUser: post.forUser,
              caption: post.caption,
              taggedCategoryId: post.taggedCategoryId,
              taggedCategoryName: post.taggedCategoryName,
              likesCount: post.likesCount,
              commentsCount: post.commentsCount,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              imageUrl: post.imageUrl,
              authorName: post.authorName,
              categoryImageUrl: post.categoryImageUrl,
              isLikedByMe: true,
            );
          }
          return post;
        }).toList();
      }

      // Combine old and new posts
      final allPosts = [...currentPosts, ...newPosts];

      emit(
        currentState.copyWith(
          posts: allPosts,
          hasMore: newPosts.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      print('❌ Error loading more posts: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Get all post IDs that current user has liked
  Future<List<String>> _getLikedPostIds(String userId) async {
    try {
      final likedPosts = await _supabase
          .from('post_favorites')
          .select('for_post')
          .eq('for_user', userId);

      return likedPosts.map((e) => e['for_post'] as String).toList();
    } catch (e) {
      print('❌ Error fetching liked posts: $e');
      return [];
    }
  }

  /// ✅ UPDATE SELECTED IMAGE
  void setSelectedImage(File? image) {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(
        currentState.copyWith(selectedImage: image, clearImage: image == null),
      );
    }
  }

  /// ✅ UPDATE SELECTED CATEGORY
  void setSelectedCategory(ExerciseCategory? category) {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  /// ✅ CLEAR SELECTED IMAGE
  void clearSelectedImage() {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      emit(
        SocialFeedLoaded(
          posts: currentState.posts,
          selectedImage: null,
          selectedCategory: currentState.selectedCategory,
          hasMore: currentState.hasMore,
          isLoadingMore: currentState.isLoadingMore,
        ),
      );
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
        'image_url': imageUrl, // 👈 Lưu URL công khai vào DB
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

    if (state is! SocialFeedLoaded) return;

    final currentState = state as SocialFeedLoaded;
    final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = currentState.posts[postIndex];
    bool isLiking = !post.isLikedByMe;

    try {
      // 🔥 Optimistic update
      List<ContentPost> updatedPosts = List.from(currentState.posts);
      updatedPosts[postIndex] = ContentPost(
        id: post.id,
        forUser: post.forUser,
        caption: post.caption,
        taggedCategoryId: post.taggedCategoryId,
        taggedCategoryName: post.taggedCategoryName,
        likesCount: isLiking
            ? (post.likesCount ?? 0) + 1
            : (post.likesCount ?? 0) - 1,
        commentsCount: post.commentsCount,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        imageUrl: post.imageUrl,
        authorName: post.authorName,
        categoryImageUrl: post.categoryImageUrl,
        isLikedByMe: isLiking,
      );

      emit(currentState.copyWith(posts: updatedPosts));

      // 🔥 Actually update the database
      final existing = await _supabase
          .from('post_favorites')
          .select()
          .eq('for_post', postId)
          .eq('for_user', userId)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await _supabase
            .from('post_favorites')
            .delete()
            .eq('for_post', postId)
            .eq('for_user', userId);
        await _supabase.rpc('decrement_likes', params: {'post_id': postId});
      } else {
        // Like
        await _supabase.from('post_favorites').insert({
          'for_post': postId,
          'for_user': userId,
        });
        await _supabase.rpc('increment_likes', params: {'post_id': postId});
      }

      // ❌ REMOVED: await loadFeed() - không cần reload vì đã có optimistic update
    } catch (e) {
      print('❌ Error like: $e');
      emit(currentState); // Revert optimistic update on error
    }
  }

  /// LOAD COMMENTS FOR A POST
  Future<void> loadComments(String postId) async {
    try {
      final comments = await _supabase
          .from('post_comments')
          .select('''
            *,
            user(username)
          ''')
          .eq('for_post', postId)
          .order('created_at', ascending: true);

      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        final mappedComments = comments
            .map(
              (e) => {
                'id': e['id'],
                'content': e['content'],
                'username': e['user']?['username'] ?? 'Anonymous',
                'created_at': e['created_at'],
              },
            )
            .toList();

        emit(currentState.copyWith(comments: mappedComments));
      }
    } catch (e) {
      print('❌ Error loading comments: $e');
    }
  }

  /// COMMENT
  Future<bool> addComment(String postId, String content) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('post_comments').insert({
        'for_post': postId,
        'for_user': userId,
        'content': content,
      });

      // ✅ Increment comments count
      try {
        await _supabase.rpc('increment_comments', params: {'post_id': postId});
      } catch (e) {
        print('⚠️ Warning: increment_comments function may not exist: $e');
      }

      // ✅ Update comments count in posts list
      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final updatedPost = currentState.posts[postIndex];
          List<ContentPost> updatedPosts = List.from(currentState.posts);
          updatedPosts[postIndex] = ContentPost(
            id: updatedPost.id,
            forUser: updatedPost.forUser,
            caption: updatedPost.caption,
            taggedCategoryId: updatedPost.taggedCategoryId,
            taggedCategoryName: updatedPost.taggedCategoryName,
            likesCount: updatedPost.likesCount,
            commentsCount: (updatedPost.commentsCount ?? 0) + 1,
            createdAt: updatedPost.createdAt,
            updatedAt: updatedPost.updatedAt,
            imageUrl: updatedPost.imageUrl,
            authorName: updatedPost.authorName,
            categoryImageUrl: updatedPost.categoryImageUrl,
            isLikedByMe: updatedPost.isLikedByMe,
          );
          emit(currentState.copyWith(posts: updatedPosts));
        }
      }

      await loadComments(postId);
      return true;
    } catch (e) {
      print('❌ Error comment: $e');
      return false;
    }
  }

  /// DELETE COMMENT
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Delete comment
      await _supabase
          .from('post_comments')
          .delete()
          .eq('id', commentId)
          .eq('for_user', userId);

      // Decrement comments count
      try {
        await _supabase.rpc('decrement_comments', params: {'post_id': postId});
      } catch (e) {
        print('⚠️ Warning: decrement_comments function may not exist: $e');
      }

      // ✅ Update comments count in posts list
      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final updatedPost = currentState.posts[postIndex];
          List<ContentPost> updatedPosts = List.from(currentState.posts);
          updatedPosts[postIndex] = ContentPost(
            id: updatedPost.id,
            forUser: updatedPost.forUser,
            caption: updatedPost.caption,
            taggedCategoryId: updatedPost.taggedCategoryId,
            taggedCategoryName: updatedPost.taggedCategoryName,
            likesCount: updatedPost.likesCount,
            commentsCount: (updatedPost.commentsCount ?? 0) - 1 < 0
                ? 0
                : (updatedPost.commentsCount ?? 0) - 1,
            createdAt: updatedPost.createdAt,
            updatedAt: updatedPost.updatedAt,
            imageUrl: updatedPost.imageUrl,
            authorName: updatedPost.authorName,
            categoryImageUrl: updatedPost.categoryImageUrl,
            isLikedByMe: updatedPost.isLikedByMe,
          );
          emit(currentState.copyWith(posts: updatedPosts));
        }
      }

      await loadComments(postId);
      return true;
    } catch (e) {
      print('❌ Error deleting comment: $e');
      return false;
    }
  }

  /// UPDATE POST
  Future<bool> updatePost({
    required String postId,
    required String caption,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('content_posts')
          .update({'caption': caption})
          .eq('id', postId)
          .eq('for_user', userId);

      // ✅ Update local state instead of reloading entire feed
      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final updatedPost = currentState.posts[postIndex];
          List<ContentPost> updatedPosts = List.from(currentState.posts);
          updatedPosts[postIndex] = ContentPost(
            id: updatedPost.id,
            forUser: updatedPost.forUser,
            caption: caption,
            taggedCategoryId: updatedPost.taggedCategoryId,
            taggedCategoryName: updatedPost.taggedCategoryName,
            likesCount: updatedPost.likesCount,
            commentsCount: updatedPost.commentsCount,
            createdAt: updatedPost.createdAt,
            updatedAt: updatedPost.updatedAt,
            imageUrl: updatedPost.imageUrl,
            authorName: updatedPost.authorName,
            categoryImageUrl: updatedPost.categoryImageUrl,
            isLikedByMe: updatedPost.isLikedByMe,
          );
          emit(currentState.copyWith(posts: updatedPosts));
        }
      }

      // ✅ Reload feed in background (không chặn dialog)
      loadFeed();

      return true;
    } catch (e) {
      print('❌ Error updating post: $e');
      return false;
    }
  }

  /// DELETE POST
  Future<bool> deletePost(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // ✅ Remove post from local state immediately (optimistic delete)
      if (state is SocialFeedLoaded) {
        final currentState = state as SocialFeedLoaded;
        final updatedPosts = currentState.posts
            .where((post) => post.id != postId)
            .toList();
        emit(currentState.copyWith(posts: updatedPosts));
      }

      // 🔥 Delete from database in background
      // Delete all comments first
      await _supabase.from('post_comments').delete().eq('for_post', postId);

      // Delete all likes
      await _supabase.from('post_favorites').delete().eq('for_post', postId);

      // Delete the post
      await _supabase
          .from('content_posts')
          .delete()
          .eq('id', postId)
          .eq('for_user', userId);

      // ✅ Reload feed in background (không chặn UI)
      loadFeed();

      return true;
    } catch (e) {
      print('❌ Error deleting post: $e');

      // ❌ Revert local state on error
      loadFeed();
      return false;
    }
  }
}
