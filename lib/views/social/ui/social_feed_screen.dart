import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final PageController _pageController = PageController();
  final List<FeedPost> _posts = [
    FeedPost(
      id: '1',
      userName: 'Nguyễn Thắng',
      userAvatar: 'https://via.placeholder.com/50',
      caption: '💪 Ngày 1 tập luyện - Cảm thấy rất tuyệt vời!',
      imageUrl: 'https://via.placeholder.com/400x500',
      likes: 234,
      comments: 12,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FeedPost(
      id: '2',
      userName: 'Linh Fitness',
      userAvatar: 'https://via.placeholder.com/50',
      caption: '🏋️ Buổi sáng tập gym - Đạt được mục tiêu!',
      imageUrl: 'https://via.placeholder.com/400x500',
      likes: 567,
      comments: 34,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FeedPost(
      id: '3',
      userName: 'Anh Hùng',
      userAvatar: 'https://via.placeholder.com/50',
      caption: '🥤 Uống nước và tập luyện mỗi ngày là chìa khóa!',
      imageUrl: 'https://via.placeholder.com/400x500',
      likes: 892,
      comments: 56,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _postContent() {
    if (_selectedImage == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh và nhập caption'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Tạo post mới
    final newPost = FeedPost(
      id: DateTime.now().toString(),
      userName: 'Bạn',
      userAvatar: 'https://via.placeholder.com/50',
      caption: _captionController.text,
      imageUrl: _selectedImage!.path,
      likes: 0,
      comments: 0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _posts.insert(0, newPost);
      _selectedImage = null;
      _captionController.clear();
    });

    // ✅ Pop bottom sheet modal
    Navigator.pop(context);

    // ✅ Hiển thị snackbar sau khi pop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã đăng bài thành công'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return PopScope(
      canPop: true, // ✅ Cho phép pop bình thường
      onPopInvoked: (didPop) {
        // ✅ Handle back button - chỉ close bottom sheet nếu đang mở
        // Không làm gì thêm, để flutter xử lý navigation mặc định
        if (didPop) {
          debugPrint('✅ PopScope: Quay lại từ SocialFeedScreen');
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Social Feed',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: TColor.primaryColor1),
              onPressed: () {},
            ),
          ],
        ),
        body: _posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: TColor.gray.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chưa có bài đăng nào',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showPostDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo bài đăng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primaryColor1,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _posts.length + 1, // ✅ +1 cho post creation card
                itemBuilder: (context, index) {
                  // ✅ Post creation card ở đầu tiên (index 0)
                  if (index == 0) {
                    return _buildPostCreationCard(textColor, theme);
                  }

                  // Danh sách bài posts (index bắt đầu từ 1)
                  return _buildPostCard(
                    _posts[index - 1],
                    textColor,
                    theme,
                  );
                },
              ),
      ),
    );
  }

  /// ✅ Build Post Creation Card
  Widget _buildPostCreationCard(Color? textColor, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ User avatar + input
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://via.placeholder.com/50'),
                backgroundColor: TColor.primaryColor1.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _showPostDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TColor.gray.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Bạn có gì mới? 💭',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Action buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _showPostDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: TColor.primaryColor1,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ảnh/Video',
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_outlined,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cảm xúc',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(FeedPost post, Color? textColor, ThemeData theme) {
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
                  backgroundImage: NetworkImage(post.userAvatar),
                  backgroundColor: TColor.primaryColor1.withOpacity(0.3),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: post.userAvatar.startsWith('http')
                      ? null
                      : Icon(Icons.person, color: TColor.primaryColor1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.timestamp),
                        style: TextStyle(
                          color: textColor?.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18),
                          SizedBox(width: 8),
                          Text('Xóa'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Post Image
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: post.imageUrl.startsWith('http')
                  ? Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CustomCircleProgIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: TColor.gray,
                            size: 60,
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(post.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: TColor.gray,
                            size: 60,
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Likes & Comments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: TColor.primaryColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          color: textColor?.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: TColor.primaryColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments}',
                        style: TextStyle(
                          color: textColor?.withOpacity(0.8),
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

          const SizedBox(height: 12),

          // ✅ Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.caption,
                  style: TextStyle(
                    color: textColor?.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: TColor.gray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tạo bài đăng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Image Picker
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: TColor.primaryColor1.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 60,
                                      color: TColor.primaryColor1,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Chọn ảnh từ thư viện',
                                      style: TextStyle(
                                        color: TColor.primaryColor1,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Caption Input
                      TextField(
                        controller: _captionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Viết caption...',
                          hintStyle: TextStyle(
                            color: TColor.gray.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColor.gray.withOpacity(0.3),
                            ),
                          ),
                          filled: true,
                          fillColor: TColor.gray.withOpacity(0.05),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ✅ Post Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _postContent(); // ✅ Call hàm
                            // ✅ Không pop ở đây - để _postContent xử lý
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primaryColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Đăng bài',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

/// ✅ Model cho FeedPost
class FeedPost {
  final String id;
  final String userName;
  final String userAvatar;
  final String caption;
  final String imageUrl;
  final int likes;
  final int comments;
  final DateTime timestamp;

  FeedPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });
}
