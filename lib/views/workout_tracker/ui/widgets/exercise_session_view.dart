import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';

class ExerciseSessionView extends StatelessWidget {
  const ExerciseSessionView({super.key});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return result ?? false;
  }

  Widget _buildExitDialog(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        if (state is! ExerciseSessionActive) return const SizedBox();

        final completedSets = state.completedSetsCount;
        final totalSets = state.sets.length * state.exercises.length;
        final incompleteSets = totalSets - completedSets;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngừng Tập',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn có chắc chắn muốn ngừng tập không?',
                  style: TextStyle(color: textColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chỉ những set hoàn thành mới được ghi lại trong lịch sử của bạn',
                  style: TextStyle(
                    color: textColor?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        completedSets.toString(),
                        'Các set đã hoàn thành',
                        textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        incompleteSets.toString(),
                        'Các set chưa hoàn thành',
                        textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                RoundButton(
                  title: 'HOÀN THÀNH',
                  onPressed: () async {
                    final saved = await context
                        .read<WorkoutTrackerCubit>()
                        .saveWorkoutSession();
                    if (saved && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'HỦY',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, Color? textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.gray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          context.read<WorkoutTrackerCubit>().stopWorkoutSession();
        }
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            onPressed: () async {
              final shouldExit = await _showExitDialog(context);
              if (shouldExit && context.mounted) {
                context.read<WorkoutTrackerCubit>().stopWorkoutSession();
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Bài tập ngực',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
          builder: (context, state) {
            if (state is! ExerciseSessionActive) {
              return Center(child: Text('No active session'));
            }

            return Column(
              children: [
                // Timer với nút kết thúc
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: TColor.black.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.access_time, color: TColor.white),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _formatTime(state.elapsedSeconds),
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (state.isFinishMode)
                        ElevatedButton(
                          onPressed: () async {
                            final shouldExit = await _showExitDialog(context);
                            if (shouldExit && context.mounted) {
                              context
                                  .read<WorkoutTrackerCubit>()
                                  .stopWorkoutSession();
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Kết thúc',
                            style: TextStyle(color: TColor.white),
                          ),
                        ),
                    ],
                  ),
                ),

                // Exercise List (collapsed view)
                if (!state.isExpanded)
                  _buildCollapsedList(context, state, textColor, cardColor),

                // Exercise Card (expanded view)
                if (state.isExpanded)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildExpandedCard(
                        context,
                        state,
                        textColor,
                        cardColor,
                      ),
                    ),
                  ),

                // Bottom Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (!state.isFinishMode)
                          InkWell(
                            onTap: () {
                              context
                                  .read<WorkoutTrackerCubit>()
                                  .enableFinishMode();
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: TColor.gray.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(Icons.check, color: textColor),
                            ),
                          ),
                        if (!state.isFinishMode) const SizedBox(width: 12),
                        Expanded(
                          child: RoundButton(
                            title: 'GHI LẠI SET TIẾP THEO',
                            onPressed: () {
                              context
                                  .read<WorkoutTrackerCubit>()
                                  .nextExercise();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedCard(
    BuildContext context,
    ExerciseSessionActive state,
    Color? textColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: state.currentExercise.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CustomCircleProgIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentExercise.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${state.completedSetsCount}/${state.sets.length} Hoàn tất',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up, color: textColor),
                onPressed: () {
                  context.read<WorkoutTrackerCubit>().toggleExpanded();
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sets List
          ...state.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return _buildSetRow(context, set, index, textColor);
          }).toList(),

          const SizedBox(height: 10),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ExerciseDetailBottomSheet.show(
                      context,
                      state.currentExercise,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: TColor.gray),
                  ),
                  child: Text('Chi tiết', style: TextStyle(color: textColor)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<WorkoutTrackerCubit>().addSet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.add, color: TColor.white),
                  label: Text(
                    'Thêm một set',
                    style: TextStyle(color: TColor.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedList(
    BuildContext context,
    ExerciseSessionActive state,
    Color? textColor,
    Color cardColor,
  ) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.exercises.length,
        itemBuilder: (context, index) {
          final exercise = state.exercises[index];
          final isCurrent = index == state.currentExerciseIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent ? cardColor : cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: isCurrent
                  ? Border.all(color: TColor.primaryColor1, width: 2)
                  : null,
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
                    placeholder: (context, url) => CustomCircleProgIndicator(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.fitness_center),
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
                      Text(
                        '0/${state.sets.length} Hoàn tất',
                        style: TextStyle(
                          color: textColor?.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down, color: textColor),
                    onPressed: () {
                      context.read<WorkoutTrackerCubit>().toggleExpanded();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, set, int index, Color? textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: TColor.gray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () {
              context.read<WorkoutTrackerCubit>().toggleSetCompletion(index);
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: set.isCompleted
                      ? TColor.primaryColor1
                      : TColor.gray.withOpacity(0.3),
                  width: 2,
                ),
                color: set.isCompleted
                    ? TColor.primaryColor1
                    : Colors.transparent,
              ),
              child: set.isCompleted
                  ? Icon(Icons.check, color: TColor.white, size: 18)
                  : null,
            ),
          ),

          const SizedBox(width: 15),

          // Set number
          Text(
            '${set.setNumber}',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 20),

          // Weight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${set.weight.toInt()}',
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text('kg', style: TextStyle(color: textColor, fontSize: 14)),

          const SizedBox(width: 20),

          // Reps
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${set.reps}',
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text('Số lần', style: TextStyle(color: textColor, fontSize: 14)),
        ],
      ),
    );
  }
}
