import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/food_details.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';

class SearchMeal extends StatefulWidget {
  const SearchMeal({super.key});

  @override
  State<SearchMeal> createState() => _SearchMealState();
}

class _SearchMealState extends State<SearchMeal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDateTime = DateTime.now();
  List<Meal> searchResults = [];
  List<Meal> recentMeals = [];
  bool _hasSearched = false; // ✅ Track nếu user đã nhập search

  final TextEditingController txtSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    txtSearch.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (txtSearch.text.isEmpty) {
      setState(() {
        searchResults = [];
        _hasSearched = false; // ✅ Reset flag khi xóa search
      });
    } else {
      setState(() => _hasSearched = true); // ✅ Set flag khi có search
      _searchMeals(txtSearch.text);
    }
  }

  Future<void> _searchMeals(String query) async {
    final results = await context.read<MealPlannerCubit>().searchMeals(query);
    setState(() => searchResults = results);
  }

  Future<void> _loadRecentMeals() async {
    final meals = await context.read<MealPlannerCubit>().getAllMeals();
    setState(() => recentMeals = meals);
  }

  // 📌 Format hiển thị AppBar
  String get formattedDateTime {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(now, _selectedDateTime);

    final dateText = isToday
        ? 'Hôm nay'
        : DateFormat('dd/MM').format(_selectedDateTime);

    final timeText = DateFormat('HH:mm').format(_selectedDateTime);

    return '$dateText • $timeText';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// 🧭 APPBAR
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: GestureDetector(
          onTap: _openDateTimePicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedDateTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: txtSearch,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Tìm thực phẩm hoặc món ăn',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          /// 📑 TABS (ẩn khi có search)
          if (!_hasSearched)
            TabBar(
              controller: _tabController,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Gần đây'),
                Tab(text: 'Tạo bởi tôi'),
              ],
            ),

          /// 📄 CONTENT
          Expanded(
            child: _hasSearched
                ? _buildSearchResults(context, theme)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecentTab(context, theme),
                      _buildEmptyState(context, title: 'Chưa có công thức'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔍 SEARCH RESULTS
  Widget _buildSearchResults(BuildContext context, ThemeData theme) {
    if (searchResults.isEmpty) {
      return _buildEmptyState(context, title: 'Không tìm thấy kết quả');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final meal = searchResults[index];
        return _buildMealCard(context, theme, meal);
      },
    );
  }

  /// 🕘 TAB GẦN ĐÂY
  Widget _buildRecentTab(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        /// 🎯 ACTION CARDS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _actionCard(
                icon: Icons.qr_code_scanner,
                label: 'Quét mã vạch',
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _actionCard(
                icon: Icons.mic,
                label: 'Ghi bằng giọng nói',
                color: Colors.orange,
              ),
            ],
          ),
        ),

        /// EMPTY STATE (không load meals khi chưa search)
        Expanded(child: _buildEmptyState(context, title: 'Chưa có thông tin')),
      ],
    );
  }

  /// ➕ ADD BUTTON
  void _addMealToPlanner(Meal meal) {
    final hour = _selectedDateTime.hour;
    String mealType = '';

    // 🕐 Xác định bữa ăn dựa vào giờ
    if (hour >= 6 && hour < 10) {
      mealType = 'breakfast';
    } else if (hour >= 10 && hour < 14) {
      mealType = 'lunch';
    } else if (hour >= 14 && hour <= 22) {
      mealType = 'dinner';
    } else {
      mealType = 'snack';
    }

    // 📡 Gọi Cubit để add meal
    context.read<MealPlannerCubit>().addMealToType(mealType, {
      'id': meal.id,
      'name': meal.name,
      'calories': meal.calories,
      'protein': meal.proteinG,
      'carbs': meal.carbsG,
      'fat': meal.fatG,
    }, _selectedDateTime);

    // ✅ Hiển thị snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.name} được thêm vào bữa ăn'),
        duration: const Duration(seconds: 2),
      ),
    );

    /// 🔙 Quay lại meal planner view
    Navigator.pop(context);
  }

  /// 🍽️ MEAL CARD (TAP ANYWHERE GOES TO DETAILS)
  Widget _buildMealCard(BuildContext context, ThemeData theme, Meal meal) {
    return GestureDetector(
      onTap: () {
        /// ✅ Navigate to food details khi nhấn vào card
        navigateTo(context, FoodDetails(meal: meal));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// 🖼️ IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: meal.imageUrl != null
                  ? Image.network(
                      meal.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),

            const SizedBox(width: 12),

            /// 📝 INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meal.isVerified)
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.servingSizeG}g • ${meal.calories} cal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// 🍯 NUTRIENT BADGES
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _nutrientBadge(
                        '⚡ ${meal.proteinG.toStringAsFixed(1)}g',
                        Colors.red,
                      ),
                      _nutrientBadge(
                        '🌾 ${meal.carbsG.toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                      _nutrientBadge(
                        '🍯 ${meal.fatG.toStringAsFixed(1)}g',
                        Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ➕ ADD BUTTON (STOP PROPAGATION)
            GestureDetector(
              onTap: () {
                _addMealToPlanner(meal);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.add, color: theme.primaryColor, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📦 IMAGE PLACEHOLDER
  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade700,
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _nutrientBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// ⏰ BOTTOM SHEET PICKER
  Future<void> _openDateTimePicker() async {
    DateTime tempDate = _selectedDateTime;
    int tempHour = _selectedDateTime.hour;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🧭 HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lựa chọn ngày & giờ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 28),
                        ),
                      ],
                    ),
                  ),

                  /// 📅 DATE + TIME PICKER
                  Expanded(
                    child: Row(
                      children: [
                        /// 📅 DATE PICKER
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: _getDayDifference(tempDate),
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime.now().add(
                                  Duration(days: index),
                                );
                              });
                            },
                            children: List.generate(
                              30,
                              (i) => Center(
                                child: Text(
                                  i == 0
                                      ? 'Hôm nay'
                                      : DateFormat('dd/MM').format(
                                          DateTime.now().add(Duration(days: i)),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// ⏰ TIME PICKER
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: tempHour,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempHour = index;
                              });
                            },
                            children: List.generate(
                              24,
                              (i) => Center(
                                child: Text(
                                  '${i.toString().padLeft(2, '0')}:00',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ✅ CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDateTime = DateTime(
                              tempDate.year,
                              tempDate.month,
                              tempDate.day,
                              tempHour,
                              0,
                            );
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lựa chọn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// 📦 EMPTY STATE
  Widget _buildEmptyState(BuildContext context, {required String title}) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Hệ thống chưa ghi nhận thông tin bạn\nđã nhập gần đây',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 📌 Tính số ngày từ hôm nay
  int _getDayDifference(DateTime dateTime) {
    final today = DateTime.now();
    final difference = dateTime
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return difference.clamp(0, 29);
  }

  @override
  void dispose() {
    _tabController.dispose();
    txtSearch.dispose();
    super.dispose();
  }
}
