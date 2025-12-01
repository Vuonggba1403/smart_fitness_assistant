import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart'; // ✅ Fix import
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/exercise_session_view.dart';

class WorkoutDetailView extends StatelessWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    // Tải danh sách exercise items khi view được tạo
    final categoryId = dObj['id'] ?? dObj['for_cate'];
    if (categoryId != null) {
      context.read<WorkoutTrackerCubit>().loadExerciseItems(
        categoryId.toString(),
      );
    }

    return Container(
      color: Colors.transparent,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(colors: TColor.primaryG),
      // ),
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
                    Hero(
                      tag: 'workout_${dObj["img_url"]}',
                      child: CachedNetworkImage(
                        imageUrl: dObj["img_url"]?.toString() ?? '',
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
                      SizedBox(height: media.width * 0.1),
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
                            onPressed: () {
                              if (state is WorkoutDetailLoaded) {
                                final categoryId = dObj['id']?.toString() ?? '';
                                final categoryName =
                                    dObj['title_ex']?.toString() ?? 'Workout';

                                context
                                    .read<WorkoutTrackerCubit>()
                                    .startWorkoutSession(
                                      state.exercises,
                                      categoryId,
                                      categoryName,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context
                                          .read<WorkoutTrackerCubit>(),
                                      child: const ExerciseSessionView(),
                                    ),
                                  ),
                                );
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

  /// Xây dựng phần header với tiêu đề và thông tin
  /// Sử dụng BlocBuilder để tính exerciseCount từ state
  Widget _buildHeader(Color? textColor) {
    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        int exerciseCount = 0;
        int duration = 0;

        // Nếu đã load xong exercises, tính số lượng và thời gian
        if (state is WorkoutDetailLoaded) {
          exerciseCount = state.exerciseCount; // ✅ Dùng getter từ state
          duration = context.read<WorkoutTrackerCubit>().calculateDuration(
            exerciseCount,
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dObj["title_ex"]?.toString() ?? "Workout",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "$exerciseCount ${LocaleKey.exercises.tr} | $duration ${LocaleKey.mins.tr} | 320 ${LocaleKey.kcal.tr}",
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

  /// Xây dựng phần danh sách thiết bị với BlocBuilder
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

  /// Xây dựng header của phần thiết bị
  /// Tính số lượng thiết bị unique từ exercises
  Widget _buildDevicesHeader(
    BuildContext context,
    WorkoutTrackerState state,
    Color? textColor,
  ) {
    int deviceCount = 0;
    if (state is WorkoutDetailLoaded) {
      final uniqueDevices = context
          .read<WorkoutTrackerCubit>()
          .getUniqueDevices(state.exercises); // ✅ Pass List<ExerciseItem>
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

  /// Xây dựng danh sách thiết bị với ảnh riêng
  Widget _buildDevicesList(
    BuildContext context,
    WorkoutTrackerState state,
    Size media,
    Color? textColor,
    Color cardColor,
  ) {
    // Đang tải dữ liệu
    if (state is WorkoutDetailLoading) {
      return CustomCircleProgIndicator();
    }

    // Có lỗi xảy ra
    if (state is WorkoutDetailError) {
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: TextStyle(color: textColor),
        ),
      );
    }

    // Không có dữ liệu hoặc trạng thái khởi tạo
    if (state is WorkoutDetailEmpty || state is WorkoutTrackerInitial) {
      return Center(
        child: Text(
          LocaleKey.noEquipment.tr,
          style: TextStyle(color: textColor?.withOpacity(0.6)),
        ),
      );
    }

    // Đã tải dữ liệu thành công
    if (state is WorkoutDetailLoaded) {
      final cubit = context.read<WorkoutTrackerCubit>();
      final exercises = state.exercises;

      // ✅ Giờ là List<Device> thay vì List<String>
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
          final device = uniqueDevices[index]; // ✅ Device object

          return _buildDeviceCard(
            device.name, // ✅ Tên device
            device.imgUrl ?? '', // ✅ Ảnh từ Device model
            media,
            textColor,
            cardColor,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  /// Xây dựng card hiển thị thiết bị
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
              // color: TColor.primaryColor1,
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

  /// Xây dựng phần danh sách exercises
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

  /// Xây dựng header của phần exercises
  Widget _buildExercisesHeader(WorkoutTrackerState state, Color? textColor) {
    int exerciseCount = 0;
    if (state is WorkoutDetailLoaded) {
      exerciseCount = state.exerciseCount; // ✅ Dùng getter từ state
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

  /// Xây dựng danh sách exercises dựa trên state
  Widget _buildExercisesList(
    WorkoutTrackerState state,
    Color? textColor,
    Color cardColor,
  ) {
    // Đang tải dữ liệu
    if (state is WorkoutDetailLoading) {
      return CustomCircleProgIndicator();
    }

    // Có lỗi xảy ra
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

    // Không có dữ liệu hoặc trạng thái khởi tạo
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

    // Đã tải dữ liệu thành công
    if (state is WorkoutDetailLoaded) {
      final exercises = state.exercises; // ✅ List<ExerciseItem>

      return ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index]; // ✅ ExerciseItem
          return _buildExerciseCard(exercise, textColor, cardColor);
        },
      );
    }

    return const SizedBox.shrink();
  }

  /// Xây dựng card hiển thị exercise
  /// Sử dụng ExerciseItem model với type-safe properties
  Widget _buildExerciseCard(
    ExerciseItem exercise, // ✅ Type-safe parameter
    Color? textColor,
    Color cardColor,
  ) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => ExerciseDetailBottomSheet.show(
          context,
          exercise, // ✅ Pass ExerciseItem object
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // color: cardColor,
            gradient: LinearGradient(
              colors: AppTheme.gradientColors2(Get.context!),
            ),
            border: Border.all(color: TColor.primaryColor1, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: exercise.imageUrl, // ✅ Type-safe property
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CustomCircleProgIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.fitness_center, size: 30, color: TColor.gray),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title, // ✅ Type-safe property
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.muscleGroupsString, // ✅ Getter from model
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
