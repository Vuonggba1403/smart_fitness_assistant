import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/custom_appbar.dart';
import 'package:smart_fitness_assistant/core/functions/navigate_to.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/views/meal_planner/logic/cubit/meal_planner_cubit.dart';
import 'package:smart_fitness_assistant/views/meal_planner/ui/food_details_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_fitness_assistant/core/services/open_food_facts_service.dart';

/// 🔍 Search Meal Page - Search and scan food
class SearchMealPage extends StatefulWidget {
  const SearchMealPage({super.key});

  @override
  State<SearchMealPage> createState() => _SearchMealPageState();
}

class _SearchMealPageState extends State<SearchMealPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    _tabController.addListener(_onTabChanged);

    // ✅ Load recent meals ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MealPlannerCubit>().loadRecentMeals();
      }
    });
  }

  /// 🔄 Xử lý khi chuyển tab
  void _onTabChanged() {
    if (!_tabController.indexIsChanging && !_isSearching) {
      if (_tabController.index == 0) {
        // ✅ Load lại recent meals khi quay về tab Recent
        context.read<MealPlannerCubit>().loadRecentMeals();
      } else if (_tabController.index == 1) {
        // ✅ Reset về empty state cho tab Created by Me
        context.read<MealPlannerCubit>().resetSearch();
      }
    }
  }

  /// 🔍 Xử lý search
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      // ✅ Khi clear search, load lại recent meals
      context.read<MealPlannerCubit>().loadRecentMeals();
    } else {
      setState(() => _isSearching = true);
      context.read<MealPlannerCubit>().searchMeals(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: LocaleKey.searchFood.tr),
      body: Column(
        children: [
          _buildSearchField(theme),
          // Chỉ hiển thị tabs khi KHÔNG search
          if (!_isSearching) _buildTabs(theme),
          Expanded(child: _buildContent()),
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
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: LocaleKey.searchFoodHint.tr,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _isSearching = false);
                    // ✅ Load lại recent meals khi clear
                    context.read<MealPlannerCubit>().loadRecentMeals();
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
        Tab(
          icon: const Icon(Icons.qr_code_scanner),
          text: LocaleKey.scanBarcode.tr,
        ),
      ],
    );
  }

  /// 📄 Nội dung chính
  Widget _buildContent() {
    // Nếu đang search, hiển thị kết quả search
    if (_isSearching) {
      return _buildSearchResults();
    }

    // Nếu không search, hiển thị tabs
    return TabBarView(
      controller: _tabController,
      children: [_buildRecentTab(), _buildBarcodeScannerTab()],
    );
  }

  /// 🔍 Kết quả search
  Widget _buildSearchResults() {
    return BlocBuilder<MealPlannerCubit, MealPlannerState>(
      builder: (context, state) {
        if (state is SearchMealLoading) {
          return CustomCircleProgIndicator();
        }

        if (state is SearchMealLoaded) {
          return _buildMealList(state.meals);
        }

        if (state is SearchMealEmpty) {
          return _buildEmptyState(LocaleKey.noResults.tr);
        }

        if (state is SearchMealError) {
          return _buildEmptyState('Error: ${state.message}');
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 🕘 Tab gần đây
  Widget _buildRecentTab() {
    return BlocBuilder<MealPlannerCubit, MealPlannerState>(
      builder: (context, state) {
        if (state is SearchMealLoading) {
          return CustomCircleProgIndicator();
        }

        if (state is SearchMealLoaded) {
          return _buildMealList(state.meals);
        }

        if (state is SearchMealEmpty) {
          return _buildEmptyState(LocaleKey.noInfoYet.tr);
        }

        // ✅ Initial state - hiển thị empty với message phù hợp
        if (state is SearchMealInitial) {
          return _buildEmptyState(LocaleKey.noInfoYet.tr);
        }

        return _buildEmptyState(LocaleKey.noInfoYet.tr);
      },
    );
  }

  /// 📷 Tab barcode scanner
  Widget _buildBarcodeScannerTab() {
    return _BarcodeScannerView(
      onMealFound: (meal) async {
        // ✅ Navigate to FoodDetails với meal từ API
        await navigateTo(context, FoodDetailsPage(meal: meal));
      },
    );
  }

  /// 📋 Danh sách meals
  Widget _buildMealList(List<Meal> meals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        return _MealCard(
          meal: meals[index],
          onTap: () => _navigateToDetails(meals[index]),
          onAdd: () => _addMealToPlanner(meals[index]),
        );
      },
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
          Text(title, style: theme.textTheme.titleMedium),
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
    navigateTo(context, FoodDetailsPage(meal: meal));
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

    AppSnackBar.success(
      context,
      '${meal.localizedName} ${LocaleKey.addedToMeal.tr}',
    );
    Navigator.pop(context); // ✅ Pop SearchMeal
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
                meal.localizedName,
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
          color: theme.primaryColor,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.add, color: Colors.white, size: 20),
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

// =====================================================
// 📷 BARCODE SCANNER VIEW
// =====================================================

/// 📱 Barcode Scanner View
class _BarcodeScannerView extends StatefulWidget {
  final Function(Meal) onMealFound;

  const _BarcodeScannerView({required this.onMealFound});

  @override
  State<_BarcodeScannerView> createState() => __BarcodeScannerViewState();
}

class __BarcodeScannerViewState extends State<_BarcodeScannerView> {
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _isScanning = false;
  String? _currentBarcode;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          formats: const [
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
            BarcodeFormat.upcA,
            BarcodeFormat.upcE,
            BarcodeFormat.qrCode,
          ],
        );
      });
    } else {
      setState(() => _hasPermission = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_isScanning) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null &&
                  barcode.rawValue != _currentBarcode) {
                _handleBarcodeDetected(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        _buildOverlay(),
        _buildInstructions(),
      ],
    );
  }

  Future<void> _handleBarcodeDetected(String barcode) async {
    setState(() {
      _isScanning = true;
      _currentBarcode = barcode;
    });

    try {
      final meal = await OpenFoodFactsService.searchByBarcode(barcode);

      if (meal != null && mounted) {
        widget.onMealFound(meal);
      } else if (mounted) {
        _showError(
          LocaleKey.barcodeNotFound.tr.replaceAll('{barcode}', barcode),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(LocaleKey.errorScanningBarcode.tr);
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isScanning = false;
          _currentBarcode = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isScanning ? Colors.green : Colors.white,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _isScanning
                  ? '🔍 Đang tìm kiếm sản phẩm...'
                  : LocaleKey.scanBarcodeInstruction.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 8),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKey.cameraPermissionRequired.tr,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: Text(LocaleKey.openSettings.tr),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
