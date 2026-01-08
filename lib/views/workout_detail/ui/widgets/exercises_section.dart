import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/models/exercise_item.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/exercise_card.dart';

/// Section displaying list of exercises in a workout category
class ExercisesSection extends StatefulWidget {
  const ExercisesSection({super.key});

  @override
  State<ExercisesSection> createState() => _ExercisesSectionState();
}

class _ExercisesSectionState extends State<ExercisesSection> {
  bool _isImagesCached = false;

  /// Pre-cache all exercise images for smooth scrolling
  Future<void> _preCacheExerciseImages(List<ExerciseItem> exercises) async {
    if (_isImagesCached || !mounted) return;

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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildHeader(state, textColor),
            _buildExercisesList(state, textColor),
          ],
        );
      },
    );
  }

  /// Build header showing exercise count
  Widget _buildHeader(WorkoutTrackerState state, Color? textColor) {
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

  /// Build vertical list of exercises
  Widget _buildExercisesList(WorkoutTrackerState state, Color? textColor) {
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
            LocaleKey.noExercisesYet.tr,
            style: TextStyle(color: textColor?.withOpacity(0.6)),
          ),
        ),
      );
    }

    if (state is WorkoutDetailLoaded) {
      final exercises = state.exercises;

      // Pre-cache images after frame renders
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
          return ExerciseCard(
            key: ValueKey('exercise_${exercise.id}'),
            exercise: exercise,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
