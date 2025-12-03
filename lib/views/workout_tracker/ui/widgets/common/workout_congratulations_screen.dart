import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';

/// Màn hình chúc mừng sau khi hoàn thành workout
/// Hiển thị thông tin:
/// - Tiêu đề chúc mừng
/// - Icon cúp vàng
/// - Tên bài tập với checkmark
/// - Thời lượng và ngày tháng
/// - Danh sách các bài tập với tiến độ hoàn thành
class WorkoutCongratulationsScreen {
  /// Hiển thị màn hình congratulations dưới dạng dialog
  static Future<void> show(
    BuildContext context,
    ExerciseSessionActive state,
  ) async {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade400, Colors.red.shade700],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiêu đề
              _buildTitle(),
              const SizedBox(height: 30),

              // Icon cúp vàng
              _buildTrophyIcon(),
              const SizedBox(height: 30),

              // Thông tin bài tập
              _buildWorkoutInfo(state, textColor),
              const SizedBox(height: 30),

              // Danh sách bài tập
              _buildExercisesList(state, textColor),
              const SizedBox(height: 20),

              // Nút hoàn thành
              _buildCompleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng tiêu đề
  static Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Tuyệt vời!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'TẬP LUYỆN\nĐÃ HOÀN THÀNH!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Xây dựng icon cúp vàng
  static Widget _buildTrophyIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.emoji_events, size: 80, color: Colors.amber),
    );
  }

  /// Xây dựng thông tin bài tập (tên, thời lượng, ngày)
  static Widget _buildWorkoutInfo(
    ExerciseSessionActive state,
    Color? textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Column(
        children: [
          // Tên bài tập với checkmark
          Text(
            '${state.categoryName} ✅',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 15),

          // Thời lượng và ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Thời lượng',
                _formatTime(state.elapsedSeconds),
                textColor,
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStatItem('Ngày', _formatDate(DateTime.now()), textColor),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng item thống kê (thời lượng/ngày)
  static Widget _buildStatItem(String label, String value, Color? textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Xây dựng danh sách bài tập với tiến độ
  static Widget _buildExercisesList(
    ExerciseSessionActive state,
    Color? textColor,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          children: state.exercises.map((exercise) {
            final exerciseIndex = state.exercises.indexOf(exercise);
            final isCompleted =
                exerciseIndex < state.currentExerciseIndex ||
                (exerciseIndex == state.currentExerciseIndex &&
                    state.isCurrentExerciseCompleted);

            final completedCount = isCompleted
                ? 4
                : (exerciseIndex == state.currentExerciseIndex
                      ? state.completedSetsCount
                      : 0);

            return _buildExerciseItem(
              exercise.imageUrl,
              exercise.title,
              completedCount,
              isCompleted,
              textColor,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Xây dựng item bài tập
  static Widget _buildExerciseItem(
    String imageUrl,
    String title,
    int completedCount,
    bool isCompleted,
    Color? textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          // Hình ảnh exercise
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Icon(Icons.fitness_center, size: 30),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin exercise
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$completedCount/4 Hoàn tất',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Số lần
          Text(
            '× 8',
            style: TextStyle(
              color: textColor?.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nút hoàn thành
  static Widget _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Hoàn thành',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Format thời gian từ giây sang MM:SS
  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format ngày giờ
  static String _formatDate(DateTime date) {
    final months = [
      'thg 01',
      'thg 02',
      'thg 03',
      'thg 04',
      'thg 05',
      'thg 06',
      'thg 07',
      'thg 08',
      'thg 09',
      'thg 10',
      'thg 11',
      'thg 12',
    ];
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }
}
