import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';
import 'package:smart_fitness_assistant/views/social/logic/cubit/social_feed_cubit.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_post_card.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_post_creation_card.dart';
import 'package:smart_fitness_assistant/views/social/ui/widgets/social_create_post_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;
  ExerciseCategory? _selectedCategory;
  bool _showEmojiPicker = false;

  final _supabase = Supabase.instance.client;

  List<ExerciseCategory>? _categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    context.read<SocialFeedCubit>(); // ✅ THÊM: Load feed
  }

  Future<void> _loadCategories() async {
    final res = await _supabase.from('exercise_categories').select();
    setState(() {
      _categories = res.map((e) => ExerciseCategory.fromJson(e)).toList();
    });
  }

  /// PICK IMAGE
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: source);
      if (img != null) {
        setState(() => _selectedImage = File(img.path));
      }
    } catch (e) {
      print('❌ pickImage error: $e');
    }
  }

  /// DIALOG SELECT IMAGE SOURCE
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: TColor.primaryColor1),
              title: const Text("Chụp ảnh"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: TColor.primaryColor1),
              title: const Text("Chọn từ thư viện"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// POST CONTENT through Cubit
  Future<void> _postContent() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    String? imageUrl;

    try {
      if (_selectedImage != null) {
        final fileName =
            'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

        await _supabase.storage
            .from('fitness_posts')
            .upload(fileName, _selectedImage!);

        imageUrl = _supabase.storage
            .from('fitness_posts')
            .getPublicUrl(fileName);
      }

      await context.read<SocialFeedCubit>().createPost(
        caption: _captionController.text,
        imageUrl: imageUrl,
        taggedCategoryId: _selectedCategory?.id,
        taggedCategoryName: _selectedCategory?.titleEx,
      );

      if (mounted) Navigator.pop(context);

      _captionController.clear();
      _selectedImage = null;
      _selectedCategory = null;
      _showEmojiPicker = false;
    } catch (e) {
      print("❌ Error posting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: CustomAppBar(title: "Diễn đàn Fitness", showBackButton: false),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<SocialFeedCubit, SocialFeedState>(
        builder: (context, state) {
          /// LOADING
          if (state is SocialFeedLoading) {
            return const Center(child: CustomCircleProgIndicator());
          }

          /// ERROR
          if (state is SocialFeedError) {
            return Center(child: Text(state.message));
          }

          /// LOADED
          if (state is SocialFeedLoaded) {
            final posts = state.posts;

            return ListView(
              children: [
                SocialPostCreationCard(
                  textColor: textColor,
                  theme: theme,
                  onTap: _showPostDialog,
                ),
                if (posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Center(
                      child: Text(
                        "Chưa có bài đăng",
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  )
                else
                  ...posts.map(
                    (post) => SocialPostCard(
                      post: post,
                      textColor: textColor,
                      theme: theme,
                      onLikeTap: () {
                        if (post.id != null && post.id!.isNotEmpty) {
                          context.read<SocialFeedCubit>().togglePostLike(
                            post.id!,
                          );
                        }
                      },
                    ),
                  ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<SocialFeedCubit>(),
        child: SocialCreatePostDialog(
          captionController: _captionController,
          selectedImage: _selectedImage,
          categories: _categories,
          selectedCategory: _selectedCategory,
          showEmojiPicker: _showEmojiPicker,
          onImagePickerTap: _showImageSourceDialog,
          onPostPressed: _postContent,
          onEmojiToggle: () {
            setState(() => _showEmojiPicker = !_showEmojiPicker);
          },
          onCategoryChanged: (c) {
            setState(() => _selectedCategory = c);
          },
          onImageRemove: () {
            setState(() => _selectedImage = null);
          },
          onShowEmojiPickerChanged: (v) {
            setState(() => _showEmojiPicker = v);
          },
        ),
      ),
    );
  }
}
