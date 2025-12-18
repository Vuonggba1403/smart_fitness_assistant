import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer; // ✅ THÊM: Import dart:developer

import 'package:smart_fitness_assistant/core/functions/cache_images_view.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/message_bubble.dart';

class ActivityLevelDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onActivitySelected;

  const ActivityLevelDialog({
    super.key,
    required this.selectedDate,
    required this.onActivitySelected,
  });

  @override
  State<ActivityLevelDialog> createState() => _ActivityLevelDialogState();
}

class _ActivityLevelDialogState extends State<ActivityLevelDialog> {
  late Future<String> _usernameFuture;
  bool _isProcessing = false;
  bool _hasTimeout = false;
  List<ActivityLevel>? _cachedLevels; // ✅ THÊM: Cache activity levels

  @override
  void initState() {
    super.initState();
    _usernameFuture = _fetchUsername();

    // ✅ Timeout sau 10 giây
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasTimeout && _cachedLevels == null) {
        developer.log(
          '⏰ TIMEOUT: Dialog loading too long',
          name: 'ActivityLevelDialog',
        );
        setState(() => _hasTimeout = true);
      }
    });
  }

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

    return BlocBuilder<MealPlannerCubit, MealPlannerState>(
      builder: (context, state) {
        developer.log(
          '📊 Current state: ${state.runtimeType}',
          name: 'ActivityLevelDialog',
        );

        // ✅ CACHE: Lưu levels khi có ActivityLevelsLoaded
        if (state is ActivityLevelsLoaded) {
          _cachedLevels = state.activityLevels;
          developer.log(
            '💾 Cached ${_cachedLevels!.length} levels',
            name: 'ActivityLevelDialog',
          );
        }

        // ✅ Hiển thị timeout error
        if (_hasTimeout && _cachedLevels == null) {
          return AlertDialog(
            title: const Text('⚠️ Lỗi tải dữ liệu'),
            content: const Text(
              'Không thể tải danh sách mức độ hoạt động. '
              'Vui lòng thử lại sau.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<MealPlannerCubit>().loadActivityLevels();
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

        // ✅ Show error state
        if (state is MealPlannerError && _cachedLevels == null) {
          developer.log(
            '❌ Error state: ${state.message}',
            name: 'ActivityLevelDialog',
          );

          return AlertDialog(
            title: const Text('❌ Lỗi'),
            content: Text(state.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<MealPlannerCubit>().loadActivityLevels();
                },
                child: const Text('Thử lại'),
              ),
            ],
          );
        }

        // ✅ THÊM: Nếu đã có cached levels, hiển thị luôn (dù state là MealsLoaded)
        if (_cachedLevels != null && _cachedLevels!.isNotEmpty) {
          developer.log(
            '✅ Using cached ${_cachedLevels!.length} activity levels',
            name: 'ActivityLevelDialog',
          );

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),

            /// 🟦 TITLE = CHAT BUBBLE
            title: FutureBuilder<String>(
              future: _usernameFuture,
              builder: (context, snapshot) {
                final username = snapshot.data ?? 'User';
                return Align(
                  alignment: Alignment.centerLeft,
                  child: MessageBubble(
                    text:
                        "Xin chào $username! Cường độ hoạt động của bạn là ...",
                  ),
                );
              },
            ),

            /// 🟨 CONTENT = ACTIVITY LIST
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
                        : () async {
                            // ✅ LOG: Start
                            developer.log(
                              '🟢 START: Selecting activity level',
                              name: 'ActivityLevelDialog',
                            );
                            developer.log(
                              'Level: ${level.title} (${level.id})',
                              name: 'ActivityLevelDialog',
                            );
                            developer.log(
                              'Activity Factor: ${level.activityFactor}',
                              name: 'ActivityLevelDialog',
                            );

                            // ✅ Prevent multiple taps
                            if (_isProcessing || !mounted) {
                              developer.log(
                                '⚠️ SKIP: Already processing or unmounted',
                                name: 'ActivityLevelDialog',
                              );
                              return;
                            }

                            setState(() => _isProcessing = true);

                            // ✅ Lưu context trước khi async
                            final dialogContext = context;

                            try {
                              developer.log(
                                '📊 STEP 1: Getting calorie info from AuthCubit',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Lấy thông tin từ AuthCubit
                              final authCubit = dialogContext
                                  .read<AuthenticationCubit>();
                              final calorieInfo = authCubit.getDailyCalories(
                                activityFactor: level.activityFactor,
                              );

                              developer.log(
                                '✅ Calorie info: $calorieInfo',
                                name: 'ActivityLevelDialog',
                              );

                              final dailyCalories =
                                  calorieInfo['tdee']?.toInt() ?? 2000;
                              final bmr = calorieInfo['bmr']?.toInt() ?? 0;

                              developer.log(
                                '📈 Calculated: BMR=$bmr, TDEE=$dailyCalories',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Show loading dialog
                              if (!mounted) {
                                developer.log(
                                  '⚠️ ABORT: Widget unmounted before loading dialog',
                                  name: 'ActivityLevelDialog',
                                );
                                return;
                              }

                              developer.log(
                                '⏳ STEP 2: Showing loading dialog',
                                name: 'ActivityLevelDialog',
                              );

                              showDialog(
                                context: dialogContext,
                                barrierDismissible: false,
                                builder: (_) => WillPopScope(
                                  onWillPop: () async => false,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );

                              developer.log(
                                '💾 STEP 3: Saving activity preference',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Save preference
                              await dialogContext
                                  .read<MealPlannerCubit>()
                                  .saveActivityPreference(
                                    level.id,
                                    dailyCalories,
                                  );

                              developer.log(
                                '✅ STEP 4: Saved successfully',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Đóng loading dialog
                              if (!mounted) {
                                developer.log(
                                  '⚠️ Widget unmounted after save',
                                  name: 'ActivityLevelDialog',
                                );
                                return;
                              }

                              developer.log(
                                '🔙 STEP 5: Closing loading dialog',
                                name: 'ActivityLevelDialog',
                              );

                              Navigator.of(
                                dialogContext,
                                rootNavigator: true,
                              ).pop();

                              /// ✅ Delay
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );

                              /// ✅ Đóng activity dialog
                              if (!mounted) {
                                developer.log(
                                  '⚠️ Widget unmounted before closing activity dialog',
                                  name: 'ActivityLevelDialog',
                                );
                                return;
                              }

                              developer.log(
                                '🔙 STEP 6: Closing activity dialog',
                                name: 'ActivityLevelDialog',
                              );

                              Navigator.of(dialogContext).pop();

                              developer.log(
                                '🔄 STEP 7: Calling onActivitySelected callback',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Callback
                              widget.onActivitySelected(widget.selectedDate);

                              developer.log(
                                '✅ STEP 8: Showing success message',
                                name: 'ActivityLevelDialog',
                              );

                              /// ✅ Success message
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
                              /// ✅ LOG ERROR với stack trace
                              developer.log(
                                '❌ ERROR: Exception occurred',
                                name: 'ActivityLevelDialog',
                                error: e,
                                stackTrace: stackTrace,
                              );

                              print('❌ FULL ERROR: $e');
                              print('❌ STACK TRACE: $stackTrace');

                              /// ✅ Đóng tất cả dialog khi lỗi
                              if (mounted) {
                                developer.log(
                                  '🔙 ERROR CLEANUP: Closing dialogs',
                                  name: 'ActivityLevelDialog',
                                );

                                try {
                                  // Pop loading dialog
                                  Navigator.of(
                                    dialogContext,
                                    rootNavigator: true,
                                  ).pop();
                                } catch (popError) {
                                  developer.log(
                                    '⚠️ Failed to pop loading dialog: $popError',
                                    name: 'ActivityLevelDialog',
                                  );
                                }

                                try {
                                  // Pop activity dialog
                                  Navigator.of(dialogContext).pop();
                                } catch (popError) {
                                  developer.log(
                                    '⚠️ Failed to pop activity dialog: $popError',
                                    name: 'ActivityLevelDialog',
                                  );
                                }

                                AppSnackBar.error(dialogContext, 'Lỗi: $e');
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isProcessing = false);
                              }
                              developer.log(
                                '🏁 FINALLY: Reset processing state',
                                name: 'ActivityLevelDialog',
                              );
                            }
                          },
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
                            /// 🟣 ICON / AVATAR FROM SUPABASE
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

                            /// 📝 TEXT (EXPANDED TO AVOID OVERFLOW)
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
                },
              ),
            ),
          );
        }

        // ✅ Show loading nếu chưa có cached levels
        developer.log('⏳ Showing loading spinner', name: 'ActivityLevelDialog');

        return const AlertDialog(
          content: SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
