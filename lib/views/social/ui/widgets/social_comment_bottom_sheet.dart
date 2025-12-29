import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';

import '../../../../locale/locale_key.dart';

class SocialCommentBottomSheet extends StatefulWidget {
  final String postId;
  final ThemeData theme;
  final Color? textColor;

  const SocialCommentBottomSheet({
    super.key,
    required this.postId,
    required this.theme,
    required this.textColor,
  });

  @override
  State<SocialCommentBottomSheet> createState() =>
      _SocialCommentBottomSheetState();
}

class _SocialCommentBottomSheetState extends State<SocialCommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<SocialFeedCubit>().loadComments(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final success = await context.read<SocialFeedCubit>().addComment(
      widget.postId,
      _commentController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      _commentController.clear();
      // Reload comments
      context.read<SocialFeedCubit>().loadComments(widget.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKey.comments.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Comments List
            Expanded(
              child: BlocBuilder<SocialFeedCubit, SocialFeedState>(
                builder: (context, state) {
                  if (state is! SocialFeedLoaded) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: TColor.primaryColor1,
                      ),
                    );
                  }

                  final comments = state.comments ?? [];

                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKey.noComments.tr,
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: const AssetImage(
                                'assets/img/u1.png',
                              ),
                              backgroundColor: TColor.primaryColor1.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['username'] ?? 'Anonymous',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment['content'] ?? '',
                                          style: TextStyle(
                                            color: textColor?.withOpacity(0.8),
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        _formatTimeAgo(
                                          DateTime.parse(
                                            comment['created_at'] ??
                                                DateTime.now()
                                                    .toIso8601String(),
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: textColor?.withOpacity(0.5),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Thích',
                                        style: TextStyle(
                                          color: textColor?.withOpacity(0.5),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input Field
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: const AssetImage('assets/img/u1.png'),
                    backgroundColor: TColor.primaryColor1.withOpacity(0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TColor.gray.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: LocaleKey.writeComments.tr,
                                hintStyle: TextStyle(
                                  color: textColor?.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          _isLoading
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CustomCircleProgIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _submitComment,
                                  icon: Icon(
                                    Icons.send,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
