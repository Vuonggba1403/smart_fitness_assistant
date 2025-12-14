import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';
import 'package:smart_fitness_assistant/core/functions/cache_images_view.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_comment_bottom_sheet.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';

/// ✅ Widget: Single Post Card
class SocialPostCard extends StatefulWidget {
  final ContentPost post;
  final Color? textColor;
  final ThemeData theme;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.textColor,
    required this.theme,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  // ✅ Kiểm tra user hiện tại có phải chủ bài hay không
  bool _isPostOwner() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId == widget.post.forUser;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialCommentBottomSheet(
        postId: widget.post.id ?? '',
        theme: widget.theme,
        textColor: widget.textColor,
      ),
    );
  }

  void _showEditDialog() {
    final editController = TextEditingController(text: widget.post.caption);
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa bài đăng'),
          content: isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Đang cập nhật...'),
                  ],
                )
              : TextField(
                  controller: editController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Chỉnh sửa caption...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
          actions: isLoading
              ? []
              : [
                  TextButton(
                    onPressed: () {
                      editController.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text('Huỷ'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);

                      final success = await context
                          .read<SocialFeedCubit>()
                          .updatePost(
                            postId: widget.post.id ?? '',
                            caption: editController.text,
                          );

                      // ✅ Close dialog immediately
                      if (mounted) {
                        editController.dispose();
                        Navigator.pop(context);
                      }

                      // ✅ Show snackbar after dialog closes
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '✅ Cập nhật thành công'
                                    : '❌ Cập nhật thất bại',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor2,
                    ),
                    child: const Text('Lưu'),
                  ),
                ],
        ),
      ),
    ).then((_) {
      editController.dispose();
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá bài đăng'),
        content: const Text('Bạn có chắc muốn xoá bài đăng này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await context
                  .read<SocialFeedCubit>()
                  .deletePost(widget.post.id ?? '');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '✅ Xoá thành công' : '❌ Xoá thất bại',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Xoá',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // ✅ User Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: const AssetImage('assets/img/u1.png'),
                  backgroundColor: TColor.primaryColor1.withOpacity(0.3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName ?? 'Anonymous',
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(widget.post.createdAt ?? DateTime.now()),
                        style: TextStyle(
                          color: widget.textColor?.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Chỉ hiển thị menu nếu user là chủ bài
                if (_isPostOwner())
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: _showEditDialog,
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: _showDeleteDialog,
                        child: Row(
                          children: const [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xoá', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.shadowColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Text(
                    widget.post.caption ?? '',
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // ✅ Ảnh bài đăng (nếu có)
                  if (widget.post.imageUrl != null &&
                      widget.post.imageUrl.toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CacheImage(
                        url: widget.post.imageUrl.toString(),
                        width: double.infinity,
                        height: 200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],

                  // ✅ Category block
                  if (widget.post.taggedCategoryName != null &&
                      widget.post.taggedCategoryName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.gradientColors1(context),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: TColor.primaryColor1.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: AppTheme.gradientColors(context),
                              ),
                            ),
                            child:
                                (widget.post.categoryImageUrl != null &&
                                    widget.post.categoryImageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CacheImage(
                                      url: widget.post.categoryImageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.fitness_center,
                                    color: TColor.primaryColor1.withOpacity(
                                      0.6,
                                    ),
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.post.taggedCategoryName ?? 'Category',
                              style: TextStyle(
                                color: TColor.primaryColor1,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Likes & Comments & Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: widget.onLikeTap,
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        color: TColor.primaryColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.likesCount ?? 0}',
                        style: TextStyle(
                          color: widget.textColor?.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => _showCommentSheet(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: TColor.primaryColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.commentsCount ?? 0}',
                        style: TextStyle(
                          color: widget.textColor?.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  color: TColor.primaryColor1,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
