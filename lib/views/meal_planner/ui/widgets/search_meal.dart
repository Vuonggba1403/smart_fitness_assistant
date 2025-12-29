import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/widgets/food_details.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';

/// 🔍 Màn hình tìm kiếm món ăn
class SearchMeal extends StatefulWidget {
  const SearchMeal({super.key});

  @override
  State<SearchMeal> createState() => _SearchMealState();
}

class _SearchMealState extends State<SearchMeal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Meal> _searchResults = [];
  bool _hasSearched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  /// 🔄 Xử lý khi text search thay đổi
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
    } else {
      setState(() => _hasSearched = true);
      _performSearch(query);
    }
  }

  /// 🔍 Thực hiện search
  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    final results = await context.read<MealPlannerCubit>().searchMeals(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKey.searchFood.tr)),
      body: Column(
        children: [
          _buildSearchField(theme),
          if (!_hasSearched) _buildTabs(theme),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  /// 🔍 Ô search
  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: LocaleKey.searchFoodHint.tr,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// 📑 Tabs
  Widget _buildTabs(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      indicatorColor: theme.primaryColor,
      tabs: [
        Tab(text: LocaleKey.recent.tr),
        Tab(text: LocaleKey.createdByMe.tr),
      ],
    );
  }

  /// 📄 Nội dung chính
  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasSearched) {
      return _buildSearchResults(theme);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildRecentTab(theme),
        _buildEmptyState(LocaleKey.noRecipes.tr),
      ],
    );
  }

  /// 🔍 Kết quả search
  Widget _buildSearchResults(ThemeData theme) {
    if (_searchResults.isEmpty) {
      return _buildEmptyState(LocaleKey.noResults.tr);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _MealCard(
          meal: _searchResults[index],
          onTap: () => _navigateToDetails(_searchResults[index]),
          onAdd: () => _addMealToPlanner(_searchResults[index]),
        );
      },
    );
  }

  /// 🕘 Tab gần đây
  Widget _buildRecentTab(ThemeData theme) {
    return Column(
      children: [Expanded(child: _buildEmptyState(LocaleKey.noInfoYet.tr))],
    );
  }

  /// 📦 Empty state
  Widget _buildEmptyState(String title) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            LocaleKey.noRecentDataMessage.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 🔀 Navigate to details
  void _navigateToDetails(Meal meal) {
    navigateTo(context, FoodDetails(meal: meal));
  }

  /// ➕ Thêm meal vào planner
  void _addMealToPlanner(Meal meal) {
    final hour = DateTime.now().hour;
    final mealType = _determineMealType(hour);

    context.read<MealPlannerCubit>().addMealToType(mealType, {
      'id': meal.id,
      'name': meal.name,
      'calories': meal.calories,
      'protein': meal.proteinG,
      'carbs': meal.carbsG,
      'fat': meal.fatG,
    }, DateTime.now());

    AppSnackBar.success(context, '${meal.name} ${LocaleKey.addedToMeal.tr}');
    Navigator.pop(context);
  }

  /// 🕐 Xác định loại bữa ăn theo giờ
  String _determineMealType(int hour) {
    if (hour >= 6 && hour < 10) return 'breakfast';
    if (hour >= 10 && hour < 14) return 'lunch';
    if (hour >= 14 && hour <= 22) return 'dinner';
    return 'snack';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// =====================================================
// 📦 HELPER WIDGETS
// =====================================================

/// 🍽️ Card hiển thị meal
class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _MealCard({
    required this.meal,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(theme)),
            _buildAddButton(theme),
          ],
        ),
      ),
    );
  }

  /// 🖼️ Ảnh món ăn
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: meal.imageUrl != null
          ? Image.network(
              meal.imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.withOpacity(0.3),
      child: const Icon(Icons.image_not_supported),
    );
  }

  /// 📝 Thông tin món ăn
  Widget _buildInfo(ThemeData theme) {
    return Column(
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
              const Icon(Icons.verified, size: 16, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${meal.servingSizeG}g • ${meal.calories} cal',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _NutrientBadge(
              label: '⚡ ${meal.proteinG.toStringAsFixed(1)}g',
              color: Colors.red,
            ),
            _NutrientBadge(
              label: '🌾 ${meal.carbsG.toStringAsFixed(1)}g',
              color: Colors.blue,
            ),
            _NutrientBadge(
              label: '🍯 ${meal.fatG.toStringAsFixed(1)}g',
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  /// ➕ Nút thêm
  Widget _buildAddButton(ThemeData theme) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.add, color: theme.primaryColor, size: 20),
      ),
    );
  }
}

/// 🏷️ Badge hiển thị nutrient
class _NutrientBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _NutrientBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
