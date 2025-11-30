import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_sliverbar.dart';
import 'package:smart_fitness_assistant/core/widgets/icon_title_next_row.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/exercises_stpe_details.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workout_schedule_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

import 'exercises_set_section.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  late Stream<List<ExerciseItem>> _exerciseItemsStream;

  @override
  void initState() {
    super.initState();
    // Khởi tạo stream cho exercise items
    final categoryId = widget.dObj['id'] ?? widget.dObj['for_cate'];
    if (categoryId != null) {
      _exerciseItemsStream = context
          .read<WorkoutTrackerCubit>()
          .streamExerciseItems(categoryId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Comment lại CustomSliverAppBar
            // CustomSliverAppBar(),
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
                    // Hero animation với ảnh
                    Hero(
                      tag: 'workout_${widget.dObj["img_url"]}',
                      child: CachedNetworkImage(
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
                    ),

                    // Back button và More button overlay
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
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
            boxShadow: [],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title_ex"]?.toString() ??
                                      widget.dObj["title"]?.toString() ??
                                      "Workout",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "${widget.dObj["exercise_count"]?.toString() ?? '0'} ${LocaleKey.exercises.tr} | ${widget.dObj["duration_mins"]?.toString() ?? '0'} ${LocaleKey.mins.tr} | 320 ${LocaleKey.kcal.tr}",
                                  style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: textColor?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: media.width * 0.05),

                      // You'll Need Section - Hiển thị devices
                      StreamBuilder<List<ExerciseItem>>(
                        stream: _exerciseItemsStream,
                        builder: (context, snapshot) {
                          // Tính số lượng thiết bị unique
                          int deviceCount = 0;
                          if (snapshot.hasData) {
                            final exercises = snapshot.data ?? [];
                            final uniqueDevices = context
                                .read<WorkoutTrackerCubit>()
                                .getUniqueDevices(exercises);
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
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Danh sách thiết bị với StreamBuilder
                      SizedBox(
                        height: media.width * 0.5,
                        child: StreamBuilder<List<ExerciseItem>>(
                          stream: _exerciseItemsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: TColor.primaryColor1,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }

                            final exercises = snapshot.data ?? [];

                            // Lấy devices unique
                            final uniqueDevices = context
                                .read<WorkoutTrackerCubit>()
                                .getUniqueDevices(exercises);

                            if (uniqueDevices.isEmpty) {
                              return Center(
                                child: Text(
                                  "No equipment needed",
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.6),
                                  ),
                                ),
                              );
                            }

                            // Lấy ảnh từ exercise đầu tiên có device
                            final exerciseWithDevice = exercises.firstWhere(
                              (e) => e.hasEquipment,
                              orElse: () => exercises.first,
                            );

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: uniqueDevices.length,
                              itemBuilder: (context, index) {
                                final deviceName = uniqueDevices[index];
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.35,
                                        width: media.width * 0.35,
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: CachedNetworkImage(
                                          imageUrl: exerciseWithDevice.imageUrl,
                                          width: media.width * 0.2,
                                          height: media.width * 0.2,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              color: TColor.primaryColor1,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                                Icons.fitness_center,
                                                color: textColor?.withOpacity(
                                                  0.3,
                                                ),
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
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: media.width * 0.05),

                      // Exercises Section với StreamBuilder
                      StreamBuilder<List<ExerciseItem>>(
                        stream: _exerciseItemsStream,
                        builder: (context, snapshot) {
                          final exerciseCount = snapshot.data?.length ?? 0;

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
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Danh sách bài tập - Tap để hiển thị bottom sheet
                      StreamBuilder<List<ExerciseItem>>(
                        stream: _exerciseItemsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: TColor.primaryColor1,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            );
                          }

                          final exercises = snapshot.data ?? [];

                          if (exercises.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "No exercises found",
                                  style: TextStyle(
                                    color: textColor?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              return InkWell(
                                /// Tap để hiển thị bottom sheet chi tiết
                                onTap: () => ExerciseDetailBottomSheet.show(
                                  context,
                                  exercise,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: exercise.imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              color: TColor.primaryColor1,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                                Icons.fitness_center,
                                                size: 30,
                                                color: TColor.gray,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              exercise.muscleGroupsString,
                                              style: TextStyle(
                                                color: textColor?.withOpacity(
                                                  0.6,
                                                ),
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
                              );
                            },
                          );
                        },
                      ),

                      SizedBox(height: media.width * 0.1),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundButton(
                        title: LocaleKey.startWorkout.tr,
                        onPressed: () {},
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
}
