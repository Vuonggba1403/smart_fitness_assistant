import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/views/exercise_session/logic/cubit/session_cubit.dart';

/// Màn hình chúc mừng sau khi hoàn thành workout
class WorkoutCongratulationsScreen extends StatelessWidget {
  final SessionActive state; // ✅ FIX: Đổi type

  const WorkoutCongratulationsScreen({super.key, required this.state});

  /// Hiển thị màn hình dưới dạng dialog
  static Future<void> show(
    BuildContext context,
    SessionActive state, // ✅ FIX: Đổi type
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorkoutCongratulationsScreen(state: state),
    );
  }

  /// Tính số sets đã hoàn thành cho một exercise cụ thể
  _ExerciseStats _getStatsForExercise(int exerciseIndex) {
    if (exerciseIndex < state.currentExerciseIndex) {
      // Bài đã hoàn thành trước đó
      return _ExerciseStats(completedSets: 4, totalSets: 4);
    } else if (exerciseIndex == state.currentExerciseIndex) {
      // Bài đang làm - Lấy số liệu thực tế
      return _ExerciseStats(
        completedSets: state.completedSetsCount,
        totalSets: state.sets.length,
      );
    } else {
      // Bài chưa làm
      return _ExerciseStats(completedSets: 0, totalSets: 4);
    }
  }

  /// Format thời gian thành MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format ngày tháng thành dd/MM/yyyy
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon cúp vàng
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
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

              /// Tiêu đề chúc mừng
              Text(
                'Tuyệt vời!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

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

              /// Thẻ thống kê
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
                    /// Tên category với checkmark
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
                            '${state.categoryName} ✓',
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

                    /// Thời lượng và ngày tháng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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

                        Container(
                          width: 1,
                          height: 40,
                          color: textColor?.withOpacity(0.2),
                        ),

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

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: textColor?.withOpacity(0.1),
                    ),

                    const SizedBox(height: 20),

                    /// Danh sách exercises với tiến độ
                    ...state.exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final stats = _getStatsForExercise(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            /// Hình ảnh exercise
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

                            /// Thông tin exercise
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
                                  Text(
                                    '${stats.completedSets}/${stats.totalSets} Hoàn tất',
                                    style: TextStyle(
                                      color: textColor?.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Số lần lặp (x số reps)
                            Text(
                              'x ${stats.completedSets * 8}',
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

              /// Nút hoàn thành
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
}

/// Class helper lưu thống kê exercise
class _ExerciseStats {
  final int completedSets;
  final int totalSets;

  _ExerciseStats({required this.completedSets, required this.totalSets});
}
