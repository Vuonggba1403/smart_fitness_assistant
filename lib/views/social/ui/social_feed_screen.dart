import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/feed_post.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_post_creation_card.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_post_card.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_create_post_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final PageController _pageController = PageController();
  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();
  bool _showEmojiPicker = false;

  List<ExerciseCategory>? _categories;
  ExerciseCategory? _selectedCategory;

  final _supabase = Supabase.instance.client;

  List<FeedPost> _posts = [];
  bool _isLoadingPosts = true;
  UserDataModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCategories();
    _loadPostsFromDatabase();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user')
          .select()
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _currentUser = UserDataModel(
            userId: response['id'] ?? '',
            username: response['username'] ?? 'Anonymous',
            height: response['height'] ?? '0',
            email: response['email'] ?? '',
            weight: response['weight'] ?? '0',
            weight_goal: response['weight_goal'] ?? '0',
            your_goals: response['your_goals'] ?? '',
          );
        });
      }
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _supabase
          .from('exercise_categories')
          .select()
          .limit(20);

      if (mounted) {
        setState(() {
          _categories = response
              .map((json) => ExerciseCategory.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
    }
  }

  Future<void> _loadPostsFromDatabase() async {
    try {
      setState(() => _isLoadingPosts = true);

      // ✅ FIX: Dùng FK relationship để JOIN với bảng user
      final response = await _supabase
          .from('content_posts')
          .select('''
            id,
            for_user,
            caption,
            image_url,
            tagged_category_id,
            tagged_category_name,
            likes_count,
            comments_count,
            created_at,
            user:for_user(username)
          ''')
          .order('created_at', ascending: false)
          .limit(50);

      final posts = <FeedPost>[];

      for (var json in response) {
        // ✅ FIX: Lấy username từ nested user object
        String userName = 'Anonymous';
        try {
          final userData = json['user'];
          if (userData is Map && userData['username'] != null) {
            userName = userData['username'] as String;
            print('✅ Username loaded: $userName');
          } else {
            userName = (json['for_user'] as String?)?.substring(0, 8) ?? 'Anonymous';
          }
        } catch (e) {
          print('⚠️ Error extracting username: $e');
          userName = (json['for_user'] as String?)?.substring(0, 8) ?? 'Anonymous';
        }

        // ✅ Load category image nếu có tagged_category_id
        String? categoryImageUrl;
        final categoryId = json['tagged_category_id'];

        if (categoryId != null && categoryId.toString().isNotEmpty) {
          try {
            final categoryResponse = await _supabase
                .from('exercise_categories')
                .select('img_url')
                .eq('id', categoryId)
                .maybeSingle();

            if (categoryResponse != null &&
                categoryResponse['img_url'] != null) {
              categoryImageUrl = categoryResponse['img_url'] as String;
            }
          } catch (e) {
            print('⚠️ Failed to load category image: $e');
          }
        }

        posts.add(
          FeedPost(
            id: json['id'] as String? ?? '',
            userId: json['for_user'] as String? ?? '',
            userName: userName, // ✅ Username từ FK join
            userAvatar: 'assets/img/u2.png',
            caption: json['caption'] as String? ?? '',
            imageUrl: json['image_url'] as String? ?? '',
            taggedCategory: json['tagged_category_name'] as String?,
            taggedCategoryId: categoryId as String?,
            categoryImageUrl: categoryImageUrl,
            likes: (json['likes_count'] as int?) ?? 0,
            comments: (json['comments_count'] as int?) ?? 0,
            timestamp: DateTime.parse(json['created_at'] as String),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
      if (mounted) {
        setState(() => _isLoadingPosts = false);
      }
    }
  }

  /// ✅ FIX: Simple error handling - BỎ permission_handler
  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      
      final pickedFile = await picker
          .pickImage(source: source)
          .timeout(const Duration(seconds: 30));

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('✅ Image selected: ${pickedFile.path}');
      }
    } on PlatformException catch (e) {
      print('❌ Platform error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.message ?? "Không thể truy cập ảnh"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Chọn nguồn ảnh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: TColor.primaryColor1),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: TColor.primaryColor1),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _postContent() async {
    if (_captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập caption'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? imageUrl;

      if (_selectedImage != null) {
        try {
          final fileName =
              'posts/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

          await _supabase.storage
              .from('fitness_posts')
              .upload(fileName, _selectedImage!);

          imageUrl =
              _supabase.storage.from('fitness_posts').getPublicUrl(fileName);

          print('✅ Image uploaded: $imageUrl');
        } catch (e) {
          print('⚠️ Image upload failed: $e');
        }
      }

      await _supabase.from('content_posts').insert({
        'for_user': userId,
        'caption': _captionController.text,
        'image_url': imageUrl,
        'tagged_category_id': _selectedCategory?.id,
        'tagged_category_name': _selectedCategory?.titleEx,
        'likes_count': 0,
        'comments_count': 0,
      });

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã đăng bài thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await _loadPostsFromDatabase();
      }
    } catch (e) {
      print('❌ Error posting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _selectedImage = null;
      _captionController.clear();
      _selectedCategory = null;
    });
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: "Diễn đàn xã hội", showBackButton: false),
      body: ListView(
        children: [
          SocialPostCreationCard(
            textColor: textColor,
            theme: theme,
            onTap: _showPostDialog,
          ),

          if (_isLoadingPosts)
            Padding(
              padding: const EdgeInsets.all(40),
              child: CustomCircleProgIndicator(),
            )
          else if (_posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 80,
                      color: TColor.gray.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chưa có bài đăng nào',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy chia sẻ khoảnh khắc tập luyện của bạn 💪',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._posts.map(
              (post) => SocialPostCard(
                post: post,
                textColor: textColor,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialCreatePostDialog(
        selectedImage: _selectedImage,
        captionController: _captionController,
        showEmojiPicker: _showEmojiPicker,
        categories: _categories,
        selectedCategory: _selectedCategory,
        onImagePickerTap: _showImageSourceDialog,
        onCategoryChanged: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
        onEmojiToggle: () {
          setState(() {
            _showEmojiPicker = !_showEmojiPicker;
          });
        },
        onPostPressed: _postContent,
        onShowEmojiPickerChanged: (value) {
          setState(() {
            _showEmojiPicker = value;
          });
        },
      ),
    );
  }
}
