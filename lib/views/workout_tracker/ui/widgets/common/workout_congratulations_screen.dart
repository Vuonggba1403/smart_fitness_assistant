import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';

/// Màn hình chúc mừng sau khi hoàn thành workout
/// Hiển thị thông tin:
/// - Tiêu đề chúc mừng
/// - Icon cúp vàng
/// - Tên bài tập với checkmark
/// - Thời lượng và ngày tháng
/// - Danh sách các bài tập với tiến độ hoàn thành
class WorkoutCongratulationsScreen extends StatelessWidget {
  final ExerciseSessionActive state;

  const WorkoutCongratulationsScreen({super.key, required this.state});

  /// Hiển thị màn hình congratulations dưới dạng dialog
  static Future<void> show(
    BuildContext context,
    ExerciseSessionActive state,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorkoutCongratulationsScreen(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    // ✅ FIX: Sử dụng getter từ state để tính chính xác
    final completedSets = state.totalCompletedSets;
    final totalSets = state.totalSetsOfAllExercises;

    return Dialog(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            // borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(25),
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TColor.primaryColor1.withOpacity(0.3),
                      TColor.primaryColor2.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Tuyệt vời!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                'TẬP LUYỆN\nĐÃ HOÀN THÀNH!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColor.primaryColor1.withOpacity(0.1),
                      TColor.primaryColor2.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // ✅ FIX: Hiển thị tên category từ state
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '${state.categoryName} ✓', // ✅ Dùng categoryName từ state
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Time and Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Time
                        Column(
                          children: [
                            Text(
                              'Thời lượng',
                              style: TextStyle(
                                color: textColor?.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formatTime(state.elapsedSeconds),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Container(
                          width: 1,
                          height: 40,
                          color: textColor?.withOpacity(0.2),
                        ),

                        // ✅ FIX: Date format
                        Column(
                          children: [
                            Text(
                              'Ngày',
                              style: TextStyle(
                                color: textColor?.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formatDate(DateTime.now()),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider line
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: textColor?.withOpacity(0.1),
                    ),

                    const SizedBox(height: 20),

                    // Exercise Details
                    ...state.exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;

                      // ✅ FIX: Tính sets cho TỪNG exercise
                      int completedSetsForExercise;
                      int totalSetsForExercise;

                      if (index < state.currentExerciseIndex) {
                        // Bài đã hoàn thành → 4/4
                        completedSetsForExercise = 4;
                        totalSetsForExercise = 4;
                      } else if (index == state.currentExerciseIndex) {
                        // ✅ Bài đang làm → Lấy số sets THỰC TẾ
                        completedSetsForExercise = state.completedSetsCount;
                        totalSetsForExercise =
                            state.sets.length; // ✅ Số sets thực tế
                      } else {
                        // Bài chưa làm
                        completedSetsForExercise = 0;
                        totalSetsForExercise = 4;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // Exercise Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: exercise.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CustomCircleProgIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.fitness_center),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Exercise Info
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // ✅ Hiển thị số sets chính xác
                                  Text(
                                    '$completedSetsForExercise/$totalSetsForExercise Hoàn tất',
                                    style: TextStyle(
                                      color: textColor?.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Multiplier (x8)
                            Text(
                              'x ${completedSetsForExercise * 8}', // ✅ 8 reps mỗi set
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Complete Button
              SizedBox(
                width: double.infinity,
                child: RoundButton(
                  title: 'Hoàn thành',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ✅ FIX: Format date đúng định dạng "dd/MM/yyyy"
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year'; // ✅ Format: 25/01/2025
  }
}
