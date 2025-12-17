import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _usernameFuture = _fetchUsername();
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
        if (state is! ActivityLevelsLoaded) {
          return const AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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
                  text: "Xin chào $username! Cường độ hoạt động của bạn là ...",
                ),
              );
            },
          ),

          /// 🟨 CONTENT = ACTIVITY LIST
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.activityLevels.length,
              itemBuilder: (context, index) {
                final level = state.activityLevels[index]; // ✅ Model

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    /// ✅ Lấy thông tin từ cubit
                    final authCubit = context.read<AuthenticationCubit>();
                    final calorieInfo = authCubit.getDailyCalories(
                      activityFactor: level.activityFactor,
                    );

                    final dailyCalories = calorieInfo['tdee']?.toInt() ?? 2000;
                    final bmr = calorieInfo['bmr']?.toInt() ?? 0;

                    context.read<MealPlannerCubit>().saveActivityPreference(
                      level.id,
                      dailyCalories,
                    );

                    // ✅ Hiển thị thông tin calo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'BMR: $bmr kcal | TDEE: $dailyCalories kcal/ngày',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context);
                    widget.onActivitySelected(widget.selectedDate);
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
      },
    );
  }
}
