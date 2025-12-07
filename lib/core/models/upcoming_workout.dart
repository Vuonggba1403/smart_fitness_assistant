class UpcomingWorkout {
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final DateTime scheduledTime;
  final int totalExercises;
  final int completedExercises;
  final bool isNotificationEnabled;

  UpcomingWorkout({
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.scheduledTime,
    required this.totalExercises,
    required this.completedExercises,
    this.isNotificationEnabled = false,
  });

  // ✅ Progress dựa trên số exercises đã hoàn thành
  double get progressPercent => totalExercises > 0
      ? (completedExercises / totalExercises).clamp(0.0, 1.0)
      : 0.0;

  bool get isCompleted => completedExercises >= totalExercises;
  bool get isInProgress =>
      completedExercises > 0 && completedExercises < totalExercises;
  bool get isToday => _isToday(scheduledTime);

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ✅ FIX: Format thời gian hiển thị đúng theo giờ đã chọn
  String get formattedTime {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hôm nay, $hour:$minute';
    }

    final day = scheduledTime.day.toString().padLeft(2, '0');
    final month = scheduledTime.month.toString().padLeft(2, '0');
    return '$day/$month, $hour:$minute';
  }

  // ✅ FIX: copyWith hỗ trợ cập nhật scheduledTime
  UpcomingWorkout copyWith({
    bool? isNotificationEnabled,
    DateTime? scheduledTime,
  }) {
    return UpcomingWorkout(
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrl: imageUrl,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
