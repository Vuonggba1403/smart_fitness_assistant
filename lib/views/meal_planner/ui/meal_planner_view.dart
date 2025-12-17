import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_calendar_agenda.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/activity_level_dialog.dart';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';

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
  TextEditingController txtSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    context.read<MealPlannerCubit>().loadMealsByDate(_selectedDate);
    context.read<MealPlannerCubit>().loadActivityLevels();

    // Show activity level dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_activityDialogShown) {
        _showActivityLevelDialog();
        _activityDialogShown = true;
      }
    });
  }

  void _showActivityLevelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivityLevelDialog(
        selectedDate: _selectedDate,
        onActivitySelected: (date) {
          context.read<MealPlannerCubit>().loadMealsByDate(date);
        },
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// ✅ HIỂN THỊ THÔNG TIN CALO
              _buildDailyCalorieCard(context, theme, textColor, media),

              // ✅ Use CustomCalendarAgenda
              CustomCalendarAgenda(
                controller: _calendarController,
                selectedDate: _selectedDate,
                textColor: textColor,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  context.read<MealPlannerCubit>().loadMealsByDate(date);
                },
              ),

              // ✅ THÊM SEARCH BOX
              Container(
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
                        decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          prefixIcon: Image.asset(
                            "assets/img/search.png",
                            width: 25,
                            height: 25,
                          ),
                          hintText: "Search Pancake",
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

              // Meals Content - Remove Expanded, use SingleChildScrollView directly
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie Container
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: BlocBuilder<MealPlannerCubit, MealPlannerState>(
                        builder: (context, state) {
                          if (state is MealsLoaded) {
                            // ✅ Mục 1: Calo hiện tại (từ những món ăn đã thêm)
                            int currentCalories = state.currentCalories;

                            // ✅ Mục 3: TDEE (tổng calo cần nạp trong ngày)
                            int targetCalories = state.targetCalories;

                            // ✅ Mục 2: Calo còn lại = Target - Current
                            int remaining = targetCalories - currentCalories;

                            double progress = currentCalories / targetCalories;

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: TColor.primaryG,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  /// ✅ 3 mục calo
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// Mục 1: Calo nhập (từ đồ ăn đã thêm)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Calo Nhập",
                                            style: TextStyle(
                                              color: TColor.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "$currentCalories",
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// Mục 2: Calo còn lại = Target - Current
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Còn Lại",
                                            style: TextStyle(
                                              color: TColor.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "$remaining",
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// Mục 3: TDEE (tổng calo cần nạp)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "TDEE",
                                            style: TextStyle(
                                              color: TColor.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "$targetCalories",
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress > 1 ? 1 : progress,
                                      minHeight: 8,
                                      backgroundColor: TColor.white.withOpacity(
                                        0.3,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        TColor.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    // Meals by Type
                    BlocListener<MealPlannerCubit, MealPlannerState>(
                      listener: (context, state) {
                        if (state is MealAdded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        } else if (state is MealPlannerError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: BlocBuilder<MealPlannerCubit, MealPlannerState>(
                        builder: (context, state) {
                          if (state is MealsLoaded) {
                            return Column(
                              children: [
                                _buildMealSection(
                                  context,
                                  "Breakfast",
                                  state.breakfast,
                                  media,
                                  textColor,
                                ),
                                _buildMealSection(
                                  context,
                                  "Lunch",
                                  state.lunch,
                                  media,
                                  textColor,
                                ),
                                _buildMealSection(
                                  context,
                                  "Dinner",
                                  state.dinner,
                                  media,
                                  textColor,
                                ),
                                SizedBox(height: media.width * 0.05),
                              ],
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
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

  /// ✅ Widget hiển thị calo hàng ngày
  Widget _buildDailyCalorieCard(
    BuildContext context,
    ThemeData theme,
    Color? textColor,
    Size media,
  ) {
    // Lấy activity factor từ cubit
    final mealPlannerCubit = context.read<MealPlannerCubit>();
    double activityFactor = mealPlannerCubit.currentActivityFactor;

    final authCubit = context.read<AuthenticationCubit>();
    final calorieInfo = authCubit.getDailyCalories(
      activityFactor: activityFactor,
    );

    final bmr = calorieInfo['bmr']?.toInt() ?? 0;
    final tdee = calorieInfo['tdee']?.toInt() ?? 0;

    return Container(
      margin: EdgeInsets.all(media.width * 0.04),
      padding: EdgeInsets.all(media.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lượng Calo Hàng Ngày',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: media.width * 0.04),
          // ✅ 3 mục calo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Mục 1: Calo nhập (bắt đầu = 0)
              _calorieInfoItem(
                title: 'Calo Nhập',
                value: '0',
                unit: 'kcal',
                icon: '🍽️',
              ),

              /// Mục 2: Calo còn lại = TDEE - 0
              _calorieInfoItem(
                title: 'Còn Lại',
                value: '$tdee',
                unit: 'kcal',
                icon: '📊',
              ),

              /// Mục 3: TDEE (tổng calo cần nạp)
              _calorieInfoItem(
                title: 'TDEE',
                value: '$tdee',
                unit: 'kcal/ngày',
                icon: '⚡',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị từng mục calo
  Widget _calorieInfoItem({
    required String title,
    required String value,
    required String unit,
    required String icon,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String mealType,
    List<Map> meals,
    Size media,
    Color? textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with time and actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    mealType,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: textColor?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _getMealTime(mealType),
                    style: TextStyle(
                      color: textColor?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Add button
              InkWell(
                onTap: () => _showAddMealDialog(context, mealType),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.add, color: TColor.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        // Meals container
        if (meals.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: meals.map((meal) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildMealItem(context, meal, mealType),
                );
              }).toList(),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'No meals added',
                style: TextStyle(
                  color: textColor?.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        SizedBox(height: media.width * 0.03),
      ],
    );
  }

  Widget _buildMealItem(BuildContext context, Map meal, String mealType) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Row(
      children: [
        Image.asset(
          meal['image'] ?? 'assets/img/placeholder.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image_not_supported),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal['name'] ?? '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${meal['size'] ?? ''} | ${meal['time'] ?? ''} | ${meal['kcal'] ?? ''}",
                style: TextStyle(
                  color: textColor?.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Delete button
        InkWell(
          onTap: () {
            if (meal['id'] != null) {
              context.read<MealPlannerCubit>().removeMealFromType(
                meal['id'] as int,
                _selectedDate,
              );
            }
          },
          child: Icon(Icons.close, color: Colors.red, size: 20),
        ),
      ],
    );
  }

  String _getMealTime(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return '7:00 AM';
      case 'Lunch':
        return '12:00 PM';
      case 'Dinner':
        return '6:30 PM';
      default:
        return '';
    }
  }

  void _showAddMealDialog(BuildContext context, String mealType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $mealType Meal'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map>>(
            future: context.read<MealPlannerCubit>().getAllRecipes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No recipes available'));
              }

              final recipes = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        recipe['image_url'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported),
                      ),
                      title: Text(recipe['name'] ?? ''),
                      subtitle: Text(
                        '${recipe['calories']}kCal | ${recipe['preparation_time']}',
                      ),
                      onTap: () {
                        final mealData = {
                          'id': recipe['id'],
                          'name': recipe['name'],
                          'image': recipe['image_url'],
                          'kcal': '${recipe['calories']}kCal',
                          'time': recipe['preparation_time'],
                          'size': recipe['difficulty_level'],
                          'b_image': recipe['image_url'],
                        };

                        context.read<MealPlannerCubit>().addMealToType(
                          mealType,
                          mealData,
                          _selectedDate,
                        );

                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    txtSearch.dispose();
    super.dispose();
  }
}
