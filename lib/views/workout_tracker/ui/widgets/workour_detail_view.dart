import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart';
import 'package:smart_fitness_assistant/views/exercise_session/ui/exercise_session_view.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

/// Màn hình hiển thị chi tiết workout category với danh sách exercises
class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView>
    with WidgetsBindingObserver {
  bool _isImagesCached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  /// Tải dữ liệu exercises từ category
  void _loadData() {
    final categoryId = widget.dObj['id'] ?? widget.dObj['for_cate'];
    if (categoryId != null) {
      context.read<WorkoutTrackerCubit>().loadExerciseItems(
        categoryId.toString(),
      );
    }
  }

  /// Pre-cache tất cả hình ảnh để tối ưu performance
  Future<void> _preCacheExerciseImages(List<ExerciseItem> exercises) async {
    if (_isImagesCached) return;

    for (final exercise in exercises) {
      try {
        await precacheImage(
          CachedNetworkImageProvider(exercise.imageUrl),
          context,
        );

        if (exercise.imgMuscleGroups != null &&
            exercise.imgMuscleGroups!.isNotEmpty) {
          await precacheImage(
            CachedNetworkImageProvider(exercise.imgMuscleGroups!),
            context,
          );
        }

        for (final device in exercise.devices) {
          if (device.imgUrl != null && device.imgUrl!.isNotEmpty) {
            await precacheImage(
              CachedNetworkImageProvider(device.imgUrl!),
              context,
            );
          }
        }
      } catch (e) {
        print('⚠️ Failed to precache: ${exercise.title}');
      }
    }

    _isImagesCached = true;
    print('✅ All images pre-cached!');
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return Container(
      color: Colors.transparent,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              pinned: false,
              floating: false,
              leadingWidth: 0,
              leading: const SizedBox(),
              automaticallyImplyLeading: false,
              expandedHeight: media.width * 0.5,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.dObj["img_url"]?.toString() ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.transparent,
                        child: CustomCircleProgIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: media.width * 0.3,
                            color: TColor.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: theme.iconTheme.color,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TColor.gray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                      _buildHeader(textColor),
                      SizedBox(height: media.width * 0.05),
                      _buildDevicesSection(media, textColor, cardColor),
                      SizedBox(height: media.width * 0.05),
                      _buildExercisesSection(textColor, cardColor),
                      SizedBox(height: media.width * 0.3),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
                        builder: (context, state) {
                          return RoundButton(
                            title: LocaleKey.startWorkout.tr,
                            onPressed: () async {
                              if (state is WorkoutDetailLoaded) {
                                final categoryId =
                                    widget.dObj['id']?.toString() ?? '';
                                final categoryName =
                                    widget.dObj['title_ex']?.toString() ??
                                    'Workout';

                                // ✅ Await result
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => SessionCubit()
                                        ..startWorkoutSession(
                                          state.exercises,
                                          categoryId,
                                          categoryName,
                                        ),
                                      child: const ExerciseSessionView(),
                                    ),
                                  ),
                                );

                                // ✅ FIX: Reload progress và emit state
                                if (result == true && mounted) {
                                  final cubit = context
                                      .read<WorkoutTrackerCubit>();

                                  // Reload progress với emit state
                                  await cubit.loadProgress(
                                    categoryId,
                                    emitState: true,
                                  );

                                  // Reload weekly stats
                                  await cubit.loadWeeklyWorkoutStats(
                                    forceRefresh: true,
                                  );

                                  // Emit DataRefreshed
                                  cubit.emit(DataRefreshed());

                                  // Reload exercises
                                  _loadData();
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header hiển thị tên category và số lượng exercises
  Widget _buildHeader(Color? textColor) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        int exerciseCount = 0;

        if (state is WorkoutDetailLoaded) {
          exerciseCount = state.exerciseCount;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dObj["title_ex"]?.toString() ?? "Workout",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "$exerciseCount ${LocaleKey.exercises.tr}",
                    style: TextStyle(
                      color: textColor?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build section hiển thị danh sách thiết bị cần dùng
  Widget _buildDevicesSection(Size media, Color? textColor, Color cardColor) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildDevicesHeader(context, state, textColor),
            SizedBox(
              height: media.width * 0.5,
              child: _buildDevicesList(
                context,
                state,
                media,
                textColor,
                cardColor,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build header của devices section
  Widget _buildDevicesHeader(
    BuildContext context,
    WorkoutTrackerState state,
    Color? textColor,
  ) {
    int deviceCount = 0;
    if (state is WorkoutDetailLoaded) {
      final uniqueDevices = context
          .read<WorkoutTrackerCubit>()
          .getUniqueDevices(state.exercises);
      deviceCount = uniqueDevices.length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKey.youNeed.tr,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "$deviceCount ${LocaleKey.item.tr}",
            style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Build danh sách thiết bị dạng horizontal scroll
  Widget _buildDevicesList(
    BuildContext context,
    WorkoutTrackerState state,
    Size media,
    Color? textColor,
    Color cardColor,
  ) {
    if (state is WorkoutDetailLoading) {
      return CustomCircleProgIndicator();
    }

    if (state is WorkoutDetailError) {
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: TextStyle(color: textColor),
        ),
      );
    }

    if (state is WorkoutDetailEmpty || state is WorkoutTrackerInitial) {
      return Center(
        child: Text(
          LocaleKey.noEquipment.tr,
          style: TextStyle(color: textColor?.withOpacity(0.6)),
        ),
      );
    }

    if (state is WorkoutDetailLoaded) {
      final cubit = context.read<WorkoutTrackerCubit>();
      final exercises = state.exercises;
      final uniqueDevices = cubit.getUniqueDevices(exercises);

      if (uniqueDevices.isEmpty) {
        return Center(
          child: Text(
            LocaleKey.noEquipment.tr,
            style: TextStyle(color: textColor?.withOpacity(0.6)),
          ),
        );
      }

      cubit.getExerciseWithDevice(exercises);

      return ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: uniqueDevices.length,
        itemBuilder: (context, index) {
          final device = uniqueDevices[index];

          return _buildDeviceCard(
            device.name,
            device.imgUrl ?? '',
            media,
            textColor,
            cardColor,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  /// Build card cho từng thiết bị
  Widget _buildDeviceCard(
    String deviceName,
    String imageUrl,
    Size media,
    Color? textColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: media.width * 0.35,
            width: media.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.primaryColor1, width: 1),
              gradient: LinearGradient(
                colors: AppTheme.gradientColors1(Get.context!),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: media.width * 0.2,
              height: media.width * 0.2,
              fit: BoxFit.contain,
              placeholder: (context, url) => CustomCircleProgIndicator(),
              errorWidget: (context, url, error) => Icon(
                Icons.fitness_center,
                color: textColor?.withOpacity(0.3),
                size: media.width * 0.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: media.width * 0.35,
              child: Text(
                deviceName,
                style: TextStyle(color: textColor, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section danh sách exercises
  Widget _buildExercisesSection(Color? textColor, Color cardColor) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildExercisesHeader(state, textColor),
            _buildExercisesList(state, textColor, cardColor),
          ],
        );
      },
    );
  }

  /// Build header của exercises section
  Widget _buildExercisesHeader(WorkoutTrackerState state, Color? textColor) {
    int exerciseCount = 0;
    if (state is WorkoutDetailLoaded) {
      exerciseCount = state.exerciseCount;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKey.exercises.tr,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "$exerciseCount ${LocaleKey.exercises.tr}",
            style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Build danh sách exercises dạng vertical list
  Widget _buildExercisesList(
    WorkoutTrackerState state,
    Color? textColor,
    Color cardColor,
  ) {
    // if (state is WorkoutDetailLoading) {
    //   return CustomCircleProgIndicator();
    // }

    if (state is WorkoutDetailError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Error: ${state.message}",
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    if (state is WorkoutDetailEmpty || state is WorkoutTrackerInitial) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No exercises found",
            style: TextStyle(color: textColor?.withOpacity(0.6)),
          ),
        ),
      );
    }

    if (state is WorkoutDetailLoaded) {
      final exercises = state.exercises;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preCacheExerciseImages(exercises);
      });

      return ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return _buildExerciseCard(
            exercise,
            textColor,
            cardColor,
            key: ValueKey('exercise_${exercise.id}'),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  /// Build card cho từng exercise
  Widget _buildExerciseCard(
    ExerciseItem exercise,
    Color? textColor,
    Color cardColor, {
    Key? key,
  }) {
    return Builder(
      key: key,
      builder: (context) => InkWell(
        onTap: () => ExerciseDetailBottomSheet.show(context, exercise),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.gradientColors2(Get.context!),
            ),
            border: Border.all(color: TColor.primaryColor1, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColor.primaryColor2, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    key: ValueKey('img_${exercise.id}'),
                    imageUrl: exercise.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    memCacheWidth: 180,
                    memCacheHeight: 180,
                    maxWidthDiskCache: 300,
                    maxHeightDiskCache: 300,
                    placeholder: (context, url) => CustomCircleProgIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.fitness_center,
                      size: 30,
                      color: TColor.gray,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "4 ${LocaleKey.sets.tr} x 8 ${LocaleKey.reps.tr}",
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
