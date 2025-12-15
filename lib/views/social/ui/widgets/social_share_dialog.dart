import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/share_helper.dart';
import 'package:smart_fitness_assistant/core/functions/cache_images_view.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';

class SocialShareDialog extends StatefulWidget {
  final ContentPost post;
  final Color? textColor;
  final ThemeData theme;

  const SocialShareDialog({
    super.key,
    required this.post,
    required this.textColor,
    required this.theme,
  });

  @override
  State<SocialShareDialog> createState() => _SocialShareDialogState();
}

class _SocialShareDialogState extends State<SocialShareDialog> {
  late Future<String> _shareLink;

  @override
  void initState() {
    super.initState();
    _shareLink = ShareHelper.generateShareLink(widget.post.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<String>(
          future: _shareLink,
          builder: (context, snapshot) {
            final shareLink = snapshot.data ?? '';
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Title
                Text(
                  'Chia sẻ bài viết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor,
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Preview Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TColor.primaryColor1.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview Image
                        if (widget.post.imageUrl != null &&
                            widget.post.imageUrl.toString().isNotEmpty)
                          CacheImage(
                            url: widget.post.imageUrl.toString(),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 150,
                            color: TColor.primaryColor1.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported,
                              color: TColor.primaryColor1.withOpacity(0.5),
                            ),
                          ),

                        // Preview Content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                widget.post.caption != null &&
                                        widget.post.caption!.isNotEmpty
                                    ? (widget.post.caption!.length > 60
                                              ? widget.post.caption!.substring(
                                                  0,
                                                  60,
                                                )
                                              : widget.post.caption!)
                                          .replaceAll('\n', ' ')
                                    : 'Chia sẻ từ Smart Fitness Assistant',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              // Description
                              Text(
                                '🏋️ ${widget.post.taggedCategoryName ?? 'Bài tập'} • Từ ${widget.post.authorName ?? 'Smart Fitness'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.textColor?.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              // Link URL
                              Text(
                                'smartfitnessassistant.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TColor.primaryColor1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Share Link
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColor.primaryColor1.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: TColor.primaryColor1.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đường link chia sẻ:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SelectableText(
                              shareLink,
                              style: TextStyle(
                                fontSize: 12,
                                color: TColor.primaryColor1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Copy Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            Clipboard.setData(ClipboardData(text: shareLink));

                            // ✅ Track share
                            await ShareHelper.trackSharedLink(
                              widget.post.id ?? '',
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Đã copy link vào clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.copy),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    label: const Text(
                      'Copy link',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Close Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        color: widget.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
