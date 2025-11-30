/// Model đại diện cho một danh mục bài tập (Exercise Category)
///
/// Chứa thông tin:
/// - id: ID unique của category
/// - title: Tên danh mục
/// - imageUrl: URL hình ảnh
/// - exerciseCount: Số lượng bài tập trong category
/// - durationMins: Thời gian ước tính (phút)
/// - createdAt: Thời gian tạo
class ExerciseCategory {
  final String id;
  final String title;
  final String imageUrl;
  final int exerciseCount;
  final int durationMins;
  final DateTime createdAt;

  ExerciseCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.exerciseCount,
    required this.durationMins,
    required this.createdAt,
  });

  /// Tạo ExerciseCategory từ JSON/Map
  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id']?.toString() ?? '',
      title: json['title_ex']?.toString() ?? 'Workout',
      imageUrl: json['img_url']?.toString() ?? '',
      exerciseCount: json['exercise_count'] as int? ?? 0,
      durationMins: json['duration_mins'] as int? ?? 0,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert ExerciseCategory sang JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ex': title,
      'img_url': imageUrl,
      'exercise_count': exerciseCount,
      'duration_mins': durationMins,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy với một số field thay đổi
  ExerciseCategory copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? exerciseCount,
    int? durationMins,
    DateTime? createdAt,
  }) {
    return ExerciseCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      durationMins: durationMins ?? this.durationMins,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
