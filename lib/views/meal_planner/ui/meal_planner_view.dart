import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'dart:developer' as developer;

import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_calendar_agenda.dart';
import 'package:smart_fitness_assistant/views/activity_level/ui/activity_level_dialog.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/search_meal.dart';
import 'package:smart_fitness_assistant/views/activity_level/logic/cubit/activity_level_cubit.dart';

class MealPlannerView extends StatefulWidget {
  final Map eObj;
  const MealPlannerView({super.key, required this.eObj});

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  final CalendarAgendaController _calendarController =
      CalendarAgendaController();

  late DateTime _selectedDate;
  bool _activityDialogShown = false;
  final TextEditingController txtSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    developer.log('🟢 MealPlannerView initState', name: 'MealPlannerView');

    // Load activity levels qua ActivityLevelCubit
    context.read<ActivityLevelCubit>().loadActivityLevels();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      developer.log('⏳ PostFrameCallback started', name: 'MealPlannerView');

      if (!_activityDialogShown && mounted) {
        developer.log(
          '🔍 Checking activity preference',
          name: 'MealPlannerView',
        );

        // Check preference qua ActivityLevelCubit
        final hasPreference = await context
            .read<ActivityLevelCubit>()
            .checkActivityPreference();

        developer.log(
          'Has preference: $hasPreference',
          name: 'MealPlannerView',
        );

        if (!hasPreference && mounted) {
          developer.log(
            '📱 Showing activity level dialog',
            name: 'MealPlannerView',
          );
          _showActivityLevelDialog();
          _activityDialogShown = true;
        } else {
          developer.log('✅ Skip showing dialog', name: 'MealPlannerView');
          if (mounted) {
            context.read<MealPlannerCubit>().loadMealsByDate(_selectedDate);
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Clean: Không cần code ở đây
  }

  /// 📱 Hiển thị activity level dialog
  void _showActivityLevelDialog() {
    developer.log(
      '🎯 _showActivityLevelDialog called',
      name: 'MealPlannerView',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<ActivityLevelCubit>(),
        child: ActivityLevelDialog(
          onActivitySaved: (activityId, dailyCalories) {
            developer.log(
              '✅ Activity selected callback',
              name: 'MealPlannerView',
            );
            context.read<MealPlannerCubit>().updateTargetCalories(
              dailyCalories,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final media = MediaQuery.of(context).size;
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.mealPlanner.tr),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<MealPlannerCubit, MealPlannerState>(
        builder: (context, state) {
          final mealsByType = state is MealsLoaded
              ? {
                  'breakfast': state.breakfast,
                  'lunch': state.lunch,
                  'dinner': state.dinner,
                }
              : <String, List<Map>>{'breakfast': [], 'lunch': [], 'dinner': []};

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔥 DAILY CALORIE CARD - ✅ Pass state từ parent
                  _buildDailyCalorieCard(context, theme, media, state),

                  /// 📅 CALENDAR
                  CustomCalendarAgenda(
                    controller: _calendarController,
                    selectedDate: _selectedDate,
                    textColor: textColor,
                    onDateSelected: (date) {
                      _selectedDate = date;
                      context.read<MealPlannerCubit>().loadMealsByDate(date);
                    },
                  ),

                  /// 🔍 SEARCH
                  Hero(
                    tag: 'meal_search_bar',
                    child: InkWell(
                      onTap: () {
                        navigateTo(context, const SearchMeal());
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: txtSearch,
                                enabled: false,
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  prefixIcon: Image.asset(
                                    "assets/img/search.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  hintText: "Tìm thực phẩm hoặc món ăn",
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 1,
                              height: 25,
                              color: TColor.gray.withOpacity(0.3),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Image.asset(
                                "assets/img/filter.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: media.width * 0.04),

                  /// 🍽️ MEALS (HIỂN THỊ MEALS ĐÃ ADD)
                  _buildMealSection(
                    context: context,
                    title: 'Bữa sáng',
                    meals: mealsByType['breakfast'] ?? [],
                    mealType: 'breakfast',
                  ),
                  _buildMealSection(
                    context: context,
                    title: 'Bữa trưa',
                    meals: mealsByType['lunch'] ?? [],
                    mealType: 'lunch',
                  ),
                  _buildMealSection(
                    context: context,
                    title: 'Bữa tối',
                    meals: mealsByType['dinner'] ?? [],
                    mealType: 'dinner',
                  ),

                  SizedBox(height: media.width * 0.04),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔥 DAILY CALORIE CARD
  Widget _buildDailyCalorieCard(
    BuildContext context,
    ThemeData theme,
    Size media,
    MealPlannerState state, // ✅ THÊM: Nhận state từ parent
  ) {
    int currentCalories = 0;
    int targetCalories = 0; // ✅ Default 0 thay vì 2000
    int remainingCalories = 0;

    if (state is MealsLoaded) {
      currentCalories = state.currentCalories;
      targetCalories = state.targetCalories;
      remainingCalories = (targetCalories - currentCalories).clamp(
        0,
        targetCalories,
      );
    }

    // ✅ Hiển thị "--" nếu chưa có target
    final targetText = targetCalories > 0 ? '$targetCalories' : '--';
    final remainingText = targetCalories > 0 ? '$remainingCalories' : '--';

    return Container(
      margin: EdgeInsets.all(media.width * 0.04),
      padding: EdgeInsets.all(media.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _calorieItem('🍽️', 'Calo nhập', '$currentCalories'),
          _calorieItem('📊', 'Còn lại', remainingText),
          _calorieItem('🎯', 'Mục tiêu', targetText),
        ],
      ),
    );
  }

  Widget _calorieItem(String icon, String title, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 🍽️ MEAL SECTION (HIỂN THỊ NHƯ HÌNH ẢNH 2)
  Widget _buildMealSection({
    required BuildContext context,
    required String title,
    required List<Map> meals,
    required String mealType,
  }) {
    final theme = Theme.of(context);
    int totalCalories = 0;

    for (var meal in meals) {
      totalCalories += (meal['calories'] as int? ?? 0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          /// 🧭 HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (meals.isNotEmpty)
                        Text(
                          meals.isNotEmpty
                              ? '🕐 ${meals.first['meal_time']}'
                              : '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (meals.isEmpty)
                  InkWell(
                    onTap: () {
                      navigateTo(context, const SearchMeal());
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// 🍜 MEALS LIST
          if (meals.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['meal_name'] ?? 'Unknown',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${meal['calories']} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock_outline, size: 18),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _removeMeal(meal['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

          /// 📊 TOTAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng: $totalCalories kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (meals.isNotEmpty)
                  InkWell(
                    onTap: () {
                      navigateTo(context, const SearchMeal());
                    },
                    child: Text(
                      '+ Thêm',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🗑️ REMOVE MEAL
  void _removeMeal(String mealId) {
    context.read<MealPlannerCubit>().removeMeal(mealId);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    txtSearch.dispose();
    super.dispose();
  }
}
