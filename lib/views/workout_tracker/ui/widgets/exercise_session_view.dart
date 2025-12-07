import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/exercise_item_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/bottom_sheet_details.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/show_dialog.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/workout_completion_bottom_sheet.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/common/workout_congratulations_screen.dart'; // ✅ Import màn hình mới

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
      builder: (dialogContext) => CustomDialog(
        title: LocaleKey.titleDialog.tr,
        content: LocaleKey.contentDialog.tr,
        okText: 'OK',
        okColor: TColor.primaryColor1,
      ),
    );
    return result ?? false;
  }

  Future<void> _showCompletionBottomSheet(BuildContext context) async {
    final state = context.read<WorkoutTrackerCubit>().state;
    if (state is! ExerciseSessionActive) return;

    final shouldFinish = await WorkoutCompletionBottomSheet.show(
      context,
      completedSets: state.totalCompletedSets,
      totalSets: state.totalSetsOfAllExercises,
    );

    if (shouldFinish == true && context.mounted) {
      // ✅ Lưu workout
      final saved = await context
          .read<WorkoutTrackerCubit>()
          .saveWorkoutSession();

      if (saved && context.mounted) {
        context.read<WorkoutTrackerCubit>().stopWorkoutSession();

        // ✅ Hiển thị congratulations
        await WorkoutCongratulationsScreen.show(context, state);

        if (context.mounted) {
          // ✅ Pop về màn hình trước (workout_detail_view)
          Navigator.pop(context);

          // ✅ Sau 100ms, pop tiếp về workout_tracker_view để force refresh
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          context.read<WorkoutTrackerCubit>().stopWorkoutSession();
          Navigator.of(context).pop();
        }
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
          title: BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
            builder: (context, state) {
              final title = state is ExerciseSessionActive
                  ? state.categoryName
                  : 'Workout';
              return Text(
                title,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              );
            },
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
                _buildTimerSection(context, state, cardColor, textColor),

                // ✅ Luôn hiển thị collapsed list
                _buildCollapsedList(context, state, textColor, cardColor),

                // Bottom Button
                _buildBottomButtons(context, state, textColor),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerSection(
    BuildContext context,
    ExerciseSessionActive state,
    Color cardColor,
    Color? textColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              onPressed: () => _showCompletionBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Kết thúc', style: TextStyle(color: TColor.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    ExerciseSessionActive state,
    Color? textColor,
  ) {
    String buttonText;
    if (state.isCurrentExerciseCompleted && state.hasNextExercise) {
      buttonText = 'BÀI TẬP TIẾP THEO';
    } else if (state.isWorkoutCompleted) {
      buttonText = 'HOÀN THÀNH';
    } else {
      buttonText = 'GHI LẠI SET ${state.completedSetsCount + 1}';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (state.isFinishMode) {
                  context.read<WorkoutTrackerCubit>().disableFinishMode();
                } else {
                  context.read<WorkoutTrackerCubit>().enableFinishMode();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: state.isFinishMode
                        ? TColor.primaryColor1
                        : textColor!,
                    width: 2,
                  ),
                  color: state.isFinishMode
                      ? TColor.primaryColor1.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.check,
                  color: state.isFinishMode ? TColor.primaryColor1 : textColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoundButton(
                title: buttonText,
                onPressed: () async {
                  if (state.isWorkoutCompleted) {
                    // ✅ Lưu workout
                    final saved = await context
                        .read<WorkoutTrackerCubit>()
                        .saveWorkoutSession();

                    if (saved && context.mounted) {
                      context.read<WorkoutTrackerCubit>().stopWorkoutSession();

                      // ✅ Hiển thị congratulations
                      await WorkoutCongratulationsScreen.show(context, state);

                      if (context.mounted) {
                        // ✅ Pop về workout_detail_view
                        Navigator.pop(context);

                        // ✅ Sau 100ms, pop tiếp về workout_tracker_view
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  } else {
                    context.read<WorkoutTrackerCubit>().nextSet();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Exercise
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

          final completedSets = _getCompletedSetsForExercise(state, index);
          final totalSets = 4;

          return BlocProvider(
            create: (_) => ExerciseItemCubit(),
            child: BlocBuilder<ExerciseItemCubit, ExerciseItemState>(
              builder: (itemContext, itemState) {
                bool isExpanded = false;
                if (itemState is ExerciseItemExpandedState) {
                  isExpanded = itemState.isExpanded;
                }

                return GestureDetector(
                  onTap: () {
                    if (isCurrent) {
                      itemContext.read<ExerciseItemCubit>().toggle();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent ? cardColor : cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: isCurrent
                          ? Border.all(color: TColor.primaryColor1, width: 2)
                          : null,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: TColor.primaryColor1.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: exercise.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CustomCircleProgIndicator(),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '$completedSets/$totalSets Hoàn tất',
                                    style: TextStyle(
                                      color: textColor?.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: textColor,
                              ),
                          ],
                        ),

                        // ✅ ANIMATED CONTENT với AnimatedCrossFade
                        if (isCurrent)
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // All sets with full editing capability
                                  ...state.sets.asMap().entries.map((entry) {
                                    final setIndex = entry.key;
                                    final set = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildSetRow(
                                        context,
                                        set,
                                        setIndex,
                                        textColor,
                                      ),
                                    );
                                  }).toList(),

                                  const SizedBox(height: 12),

                                  // Action buttons
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
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            side: BorderSide(color: TColor.gray),
                                          ),
                                          child: Text(
                                            'Chi tiết',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context
                                                .read<WorkoutTrackerCubit>()
                                                .addSet();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: TColor.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.add,
                                            color: TColor.white,
                                            size: 18,
                                          ),
                                          label: Text(
                                            'Thêm set',
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200), // ✅ Animation 200ms
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// ✅ Method helper: Tính số sets đã hoàn thành cho TỪNG exercise
  int _getCompletedSetsForExercise(
    ExerciseSessionActive state,
    int exerciseIndex,
  ) {
    if (exerciseIndex < state.currentExerciseIndex) {
      // Bài đã hoàn thành → 4/4
      return 4;
    } else if (exerciseIndex == state.currentExerciseIndex) {
      // Bài đang làm → Đếm số sets thực tế
      return state.completedSetsCount;
    } else {
      // Bài chưa làm → 0/4
      return 0;
    }
  }

  Widget _buildSetRow(BuildContext context, set, int index, Color? textColor) {
    return _EditableSetRow(set: set, index: index, textColor: textColor);
  }
}

/// Widget riêng cho mỗi set row để quản lý TextEditingController
class _EditableSetRow extends StatefulWidget {
  final dynamic set;
  final int index;
  final Color? textColor;

  const _EditableSetRow({
    required this.set,
    required this.index,
    required this.textColor,
  });

  @override
  State<_EditableSetRow> createState() => _EditableSetRowState();
}

class _EditableSetRowState extends State<_EditableSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: '${widget.set.weight.toInt()}',
    );
    _repsController = TextEditingController(text: '${widget.set.reps}');
  }

  @override
  void didUpdateWidget(_EditableSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật controller khi widget rebuild với giá trị mới
    if (oldWidget.set.weight != widget.set.weight) {
      _weightController.text = '${widget.set.weight.toInt()}';
    }
    if (oldWidget.set.reps != widget.set.reps) {
      _repsController.text = '${widget.set.reps}';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Thêm màu xanh lá cây khi set hoàn thành
    final backgroundColor = widget.set.isCompleted
        ? Colors.green.withOpacity(0.15)
        : TColor.gray.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor, // ✅ Đổi màu nền
        borderRadius: BorderRadius.circular(15),
        border: widget.set.isCompleted
            ? Border.all(color: Colors.green, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () {
              context.read<WorkoutTrackerCubit>().toggleSetCompletion(
                widget.index,
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.set.isCompleted
                      ? Colors
                            .green // ✅ Đổi màu checkbox thành xanh lá
                      : TColor.gray.withOpacity(0.3),
                  width: 2,
                ),
                color: widget.set.isCompleted
                    ? Colors
                          .green // ✅ Đổi màu checkbox thành xanh lá
                    : Colors.transparent,
              ),
              child: widget.set.isCompleted
                  ? Icon(Icons.check, color: TColor.white, size: 18)
                  : null,
            ),
          ),

          const SizedBox(width: 15),

          // Set number
          Text(
            '${widget.set.setNumber}',
            style: TextStyle(
              color: widget.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 20),

          // Weight (editable TextField)
          Container(
            width: 50,
            height: 36,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final number = int.tryParse(value);
                if (number != null && number > 0) {
                  context.read<WorkoutTrackerCubit>().updateSetWeight(
                    widget.index,
                    number.toDouble(),
                  );
                }
              },
            ),
          ),

          const SizedBox(width: 10),

          Text('kg', style: TextStyle(color: widget.textColor, fontSize: 14)),

          const SizedBox(width: 20),

          // Reps (editable TextField)
          Container(
            width: 50,
            height: 36,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final number = int.tryParse(value);
                if (number != null && number > 0) {
                  context.read<WorkoutTrackerCubit>().updateSetReps(
                    widget.index,
                    number,
                  );
                }
              },
            ),
          ),

          const SizedBox(width: 10),

          Text(
            'Số lần',
            style: TextStyle(color: widget.textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
