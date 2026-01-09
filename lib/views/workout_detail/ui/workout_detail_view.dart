import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart';
import 'package:smart_fitness_assistant/views/exercise_session/ui/exercise_session_view.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/devices_section.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/exercises_section.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';

/// Màn hình chi tiết lộ trình tập luyện.
/// Hiển thị thông tin tổng quan, danh sách thiết bị yêu cầu và các bài tập cụ thể.
class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView>
    with WidgetsBindingObserver {
  late final ExerciseCategory _category;
  late final String _categoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Khởi tạo dữ liệu model một lần duy nhất từ dObj
    _category = ExerciseCategory.fromJson(widget.dObj as Map<String, dynamic>);
    _categoryId =
        widget.dObj['id']?.toString() ??
        widget.dObj['for_cate']?.toString() ??
        '';

    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadInitialData();
  }

  /// Tải danh sách bài tập dựa trên category ID hiện tại.
  void _loadInitialData() {
    if (_categoryId.isNotEmpty) {
      context.read<WorkoutTrackerCubit>().loadExerciseItems(_categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.cardColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          // Header với hình ảnh nền và nút quay lại
          SliverAppBar(
            expandedHeight: media.width * 0.5,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _category.imgUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Center(child: CustomCircleProgIndicator()),
                    errorWidget: (_, __, ___) =>
                        Image.asset("assets/img/no-sport.png"),
                  ),
                  // Nút quay lại (Back Button)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.cardColor.withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Stack(
          children: [
            // Nội dung chi tiết lộ trình
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Drag indicator giả
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TColor.gray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phần tiêu đề và số lượng bài tập
                  BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
                    builder: (context, state) {
                      final count = (state is WorkoutDetailLoaded)
                          ? state.exerciseCount
                          : 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _category.localizedTitleEx,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$count ${LocaleKey.exercises.tr}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TColor.gray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const DevicesSection(),
                  const SizedBox(height: 20),
                  const ExercisesSection(),
                  SizedBox(
                    height: media.width * 0.3,
                  ), // Padding tránh nút Start che mất nội dung
                ],
              ),
            ),

            // Nút "Bắt đầu tập luyện" cố định ở phía dưới
            _buildStickyStartButton(),
          ],
        ),
      ),
    );
  }

  /// Nút Start Workout được đặt trong một SafeArea và Align để luôn nằm ở bottom.
  Widget _buildStickyStartButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
            builder: (context, state) {
              final isLoaded = state is WorkoutDetailLoaded;
              return RoundButton(
                title: LocaleKey.startWorkout.tr,
                onPressed: isLoaded
                    ? () => _handleStartSession(state.exercises)
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Xử lý logic khi người dùng nhấn bắt đầu buổi tập.
  Future<void> _handleStartSession(List exercises) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SessionCubit()
            ..startWorkoutSession(
              exercises.cast<ExerciseItem>(),
              _categoryId,
              _category.localizedTitleEx,
            ),
          child: const ExerciseSessionView(),
        ),
      ),
    );

    // Refresh lại dữ liệu tiến độ nếu người dùng hoàn thành buổi tập
    if (result == true && mounted) {
      final cubit = context.read<WorkoutTrackerCubit>();
      await Future.wait([
        cubit.loadProgress(_categoryId, emitState: true),
        cubit.loadWeeklyWorkoutStats(forceRefresh: true),
      ]);
      cubit.emit(DataRefreshed());
    }
  }
}
