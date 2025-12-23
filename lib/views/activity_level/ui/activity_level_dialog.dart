import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import 'package:smart_fitness_assistant/core/functions/cache_images_view.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/activity_level/logic/cubit/activity_level_cubit.dart';
import 'package:smart_fitness_assistant/views/activity_level/ui/widgets/message_bubble.dart';

/// 📱 Dialog chọn activity level cho user
class ActivityLevelDialog extends StatefulWidget {
  final Function(String activityId, int dailyCalories)? onActivitySaved;

  const ActivityLevelDialog({super.key, this.onActivitySaved});

  @override
  State<ActivityLevelDialog> createState() => _ActivityLevelDialogState();
}

class _ActivityLevelDialogState extends State<ActivityLevelDialog> {
  late Future<String> _usernameFuture;
  bool _isProcessing = false;
  bool _hasTimeout = false;
  List<ActivityLevel>? _cachedLevels;

  @override
  void initState() {
    super.initState();
    _usernameFuture = _fetchUsername();

    // Timeout sau 5 giây để tránh loading vô tận
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_hasTimeout && _cachedLevels == null) {
        developer.log(
          '⏰ TIMEOUT: Dialog loading too long',
          name: 'ActivityLevelDialog',
        );
        setState(() => _hasTimeout = true);
      }
    });
  }

  /// 👤 Lấy username từ Supabase auth
  Future<String> _fetchUsername() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user?.userMetadata != null &&
          user!.userMetadata!.containsKey('name')) {
        return user.userMetadata!['name'] as String;
      }

      return user?.email?.split('@').first ?? 'User';
    } catch (_) {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return BlocBuilder<ActivityLevelCubit, ActivityLevelState>(
      builder: (context, state) {
        developer.log(
          '📊 Current state: ${state.runtimeType}',
          name: 'ActivityLevelDialog',
        );

        // Cache levels khi load thành công
        if (state is ActivityLevelsLoaded) {
          _cachedLevels = state.activityLevels;
          developer.log(
            '💾 Cached ${_cachedLevels!.length} levels',
            name: 'ActivityLevelDialog',
          );
        }

        // Hiển thị timeout error
        if (_hasTimeout && _cachedLevels == null) {
          return _buildTimeoutDialog(context);
        }

        // Hiển thị error state
        if (state is ActivityLevelError && _cachedLevels == null) {
          return _buildErrorDialog(context, state.message);
        }

        // Hiển thị danh sách activity levels
        if (_cachedLevels != null && _cachedLevels!.isNotEmpty) {
          return _buildLevelSelectionDialog(context, theme, cardColor);
        }

        // Hiển thị loading
        return _buildLoadingDialog();
      },
    );
  }

  /// ⏰ Dialog timeout
  Widget _buildTimeoutDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Lỗi tải dữ liệu'),
      content: const Text(
        'Không thể tải danh sách mức độ hoạt động. Vui lòng thử lại sau.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<ActivityLevelCubit>().loadActivityLevels();
          },
          child: const Text('Thử lại'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  /// ❌ Dialog error
  Widget _buildErrorDialog(BuildContext context, String message) {
    return AlertDialog(
      title: const Text('❌ Lỗi'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<ActivityLevelCubit>().loadActivityLevels();
          },
          child: const Text('Thử lại'),
        ),
      ],
    );
  }

  /// ⏳ Dialog loading
  Widget _buildLoadingDialog() {
    return const AlertDialog(
      content: SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// 📋 Dialog chọn activity level
  Widget _buildLevelSelectionDialog(
    BuildContext context,
    ThemeData theme,
    Color cardColor,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: FutureBuilder<String>(
        future: _usernameFuture,
        builder: (context, snapshot) {
          final username = snapshot.data ?? 'User';
          return Align(
            alignment: Alignment.centerLeft,
            child: MessageBubble(
              text: "Xin chào $username! Cường độ hoạt động của bạn là ...",
            ),
          );
        },
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _cachedLevels!.length,
          itemBuilder: (context, index) {
            final level = _cachedLevels![index];
            return _buildLevelCard(context, theme, cardColor, level);
          },
        ),
      ),
    );
  }

  /// 🏷️ Card hiển thị từng activity level
  Widget _buildLevelCard(
    BuildContext context,
    ThemeData theme,
    Color cardColor,
    ActivityLevel level,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isProcessing ? null : () => _handleLevelSelection(context, level),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.25 : 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon từ Supabase
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: CacheImage(url: level.icon ?? '', width: 36, height: 36),
              ),
              const SizedBox(width: 12),
              // Thông tin level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Xử lý khi user chọn activity level
  Future<void> _handleLevelSelection(
    BuildContext context,
    ActivityLevel level,
  ) async {
    if (_isProcessing || !mounted) return;

    setState(() => _isProcessing = true);

    final dialogContext = context;

    try {
      developer.log(
        '🟢 START: Selecting activity level',
        name: 'ActivityLevelDialog',
      );

      // Lấy calorie info từ AuthCubit
      final authCubit = dialogContext.read<AuthenticationCubit>();
      final calorieInfo = authCubit.getDailyCalories(
        activityFactor: level.activityFactor,
      );

      final dailyCalories = calorieInfo['tdee']?.toInt() ?? 2000;

      // Hiển thị loading dialog
      if (!mounted) return;
      _showLoadingDialog(dialogContext);

      // Lưu preference vào database
      await dialogContext.read<ActivityLevelCubit>().saveActivityPreference(
        level.id,
        dailyCalories,
      );

      // Đóng loading dialog
      if (!mounted) return;
      Navigator.of(dialogContext, rootNavigator: true).pop();

      await Future.delayed(const Duration(milliseconds: 100));

      // Đóng activity dialog
      if (!mounted) return;
      Navigator.of(dialogContext).pop();

      // Callback về parent
      widget.onActivitySaved?.call(level.id, dailyCalories);

      // Hiển thị success message
      if (mounted) {
        AppSnackBar.success(
          dialogContext,
          'Đã lưu: Mục tiêu $dailyCalories kcal/ngày',
        );
      }

      developer.log(
        '🎉 SUCCESS: Completed all steps',
        name: 'ActivityLevelDialog',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR: Exception occurred',
        name: 'ActivityLevelDialog',
        error: e,
        stackTrace: stackTrace,
      );

      _handleError(dialogContext, e);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// ⏳ Hiển thị loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// ❌ Xử lý lỗi
  void _handleError(BuildContext context, dynamic error) {
    if (!mounted) return;

    // Đóng loading dialog
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}

    // Đóng activity dialog
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    // Hiển thị error message
    AppSnackBar.error(context, 'Lỗi: $error');
  }
}
