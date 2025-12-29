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

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _cachedLevels == null) {
        developer.log('⏰ TIMEOUT', name: 'ActivityLevelDialog');
        setState(() => _hasTimeout = true);
      }
    });
  }

  Future<String> _fetchUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'User';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return BlocBuilder<ActivityLevelCubit, ActivityLevelState>(
      builder: (context, state) {
        if (state is ActivityLevelsLoaded) {
          _cachedLevels = state.activityLevels;
        }

        /// ⏰ TIMEOUT
        if (_hasTimeout && _cachedLevels == null) {
          return AlertDialog(
            title: const Text('⚠️ Lỗi tải dữ liệu'),
            content: const Text(
              'Không thể tải danh sách mức độ hoạt động. Vui lòng thử lại.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ActivityLevelCubit>().loadActivityLevels();
                },
                child: const Text('Thử lại'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          );
        }

        /// ❌ ERROR
        if (state is ActivityLevelError && _cachedLevels == null) {
          return AlertDialog(
            title: const Text('❌ Lỗi'),
            content: Text(state.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ActivityLevelCubit>().loadActivityLevels();
                },
                child: const Text('Thử lại'),
              ),
            ],
          );
        }

        /// ⏳ LOADING
        if (_cachedLevels == null) {
          return const AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        /// 📋 MAIN DIALOG
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          title: FutureBuilder<String>(
            future: _usernameFuture,
            builder: (_, snap) {
              return MessageBubble(
                text:
                    'Xin chào ${snap.data ?? 'User'}! Cường độ hoạt động của bạn là ...',
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

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isProcessing
                      ? null
                      : () => _onSelectLevel(context, level),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
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
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: CacheImage(
                            url: level.icon ?? '',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// ✅ xử lý chọn level (logic giữ nguyên)
  Future<void> _onSelectLevel(BuildContext context, ActivityLevel level) async {
    if (_isProcessing || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final authCubit = context.read<AuthenticationCubit>();
      final calorieInfo = authCubit.getDailyCalories(
        activityFactor: level.activityFactor,
      );

      final dailyCalories = calorieInfo['tdee']?.toInt() ?? 2000;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await context.read<ActivityLevelCubit>().saveActivityPreference(
        level.id,
        dailyCalories,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();

      widget.onActivitySaved?.call(level.id, dailyCalories);

      AppSnackBar.success(context, 'Đã lưu: Mục tiêu $dailyCalories kcal/ngày');
    } catch (e) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      } catch (_) {}

      AppSnackBar.error(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
