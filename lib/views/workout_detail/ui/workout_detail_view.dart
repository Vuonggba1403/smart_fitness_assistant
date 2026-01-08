import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart';
import 'package:smart_fitness_assistant/views/exercise_session/ui/exercise_session_view.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/devices_section.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/exercises_section.dart';

/// Workout detail screen displaying category info, devices, and exercises
class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView>
    with WidgetsBindingObserver {
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

  /// Load exercises from category
  void _loadData() {
    final categoryId = widget.dObj['id'] ?? widget.dObj['for_cate'];
    if (categoryId != null) {
      context.read<WorkoutTrackerCubit>().loadExerciseItems(
        categoryId.toString(),
      );
    }
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
          return [_buildSliverAppBar(media, cardColor, theme)];
        },
        body: _buildBody(media, textColor, cardColor),
      ),
    );
  }

  /// Build SliverAppBar with category image
  Widget _buildSliverAppBar(Size media, Color cardColor, ThemeData theme) {
    return SliverAppBar(
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
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
    );
  }

  /// Build main body content
  Widget _buildBody(Size media, Color? textColor, Color cardColor) {
    return Container(
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
                  _buildDragHandle(),
                  SizedBox(height: media.width * 0.05),
                  _buildHeader(textColor),
                  SizedBox(height: media.width * 0.05),
                  const DevicesSection(),
                  SizedBox(height: media.width * 0.05),
                  const ExercisesSection(),
                  SizedBox(height: media.width * 0.3),
                ],
              ),
            ),
            _buildStartWorkoutButton(),
          ],
        ),
      ),
    );
  }

  /// Build drag handle indicator
  Widget _buildDragHandle() {
    return Container(
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: TColor.gray.withOpacity(0.3),
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
    );
  }

  /// Build header showing category name and exercise count
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
                    ExerciseCategory.fromJson(
                      widget.dObj as Map<String, dynamic>,
                    ).localizedTitleEx,
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

  /// Build start workout button at bottom
  Widget _buildStartWorkoutButton() {
    return SafeArea(
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
                    final categoryId = widget.dObj['id']?.toString() ?? '';
                    final category = ExerciseCategory.fromJson(
                      widget.dObj as Map<String, dynamic>,
                    );
                    final categoryName = category.localizedTitleEx;

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

                    // Reload progress after workout session
                    if (result == true && mounted) {
                      final cubit = context.read<WorkoutTrackerCubit>();

                      await cubit.loadProgress(categoryId, emitState: true);
                      await cubit.loadWeeklyWorkoutStats(forceRefresh: true);
                      cubit.emit(DataRefreshed());
                      _loadData();
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
