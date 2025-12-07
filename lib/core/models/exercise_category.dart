import 'package:equatable/equatable.dart';

/// Model đại diện cho một danh mục bài tập (Exercise Category)
/// Map trực tiếp từ bảng exercise_categories trong Supabase
///
/// Chứa thông tin:
/// - id: ID unique của category
/// - createdAt: Thời gian tạo
/// - imgUrl: URL hình ảnh
/// - titleEx: Tên danh mục
/// - exerciseItems: Danh sách các bài tập (nếu có join)
/// - classify: Phân loại 'gym' hoặc 'home'
class ExerciseCategory extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? imgUrl;
  final String? titleEx;
  final List<dynamic>? exerciseItems;
  final String? classify;

  const ExerciseCategory({
    this.id,
    this.createdAt,
    this.imgUrl,
    this.titleEx,
    this.exerciseItems,
    this.classify,
  });

  /// Tạo ExerciseCategory từ JSON/Map
  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imgUrl: json['img_url'] as String?,
      titleEx: json['title_ex'] as String?,
      exerciseItems: json['exercise_items'] as List<dynamic>?,
      classify: json['classify'] as String?,
    );
  }

  /// Convert sang JSON/Map
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt?.toIso8601String(),
    'img_url': imgUrl,
    'title_ex': titleEx,
    'exercise_items': exerciseItems,
    'classify': classify,
  };

  /// Copy với một số field thay đổi
  ExerciseCategory copyWith({
    String? id,
    DateTime? createdAt,
    String? imgUrl,
    String? titleEx,
    List<dynamic>? exerciseItems,
    String? classify,
  }) {
    return ExerciseCategory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      imgUrl: imgUrl ?? this.imgUrl,
      titleEx: titleEx ?? this.titleEx,
      exerciseItems: exerciseItems ?? this.exerciseItems,
      classify: classify ?? this.classify,
    );
  }

  // ✅ Helper methods - Support đúng giá trị tiếng Việt trong DB
  bool get isGymCategory {
    final classifyValue = classify?.toLowerCase().trim();
    return classifyValue == 'gym' || classifyValue == 'bài tập tại phòng gym';
  }

  bool get isHomeCategory {
    final classifyValue = classify?.toLowerCase().trim();
    return classifyValue == 'home' || classifyValue == 'bài tập tại nhà';
  }

  // String get classifyLabel => isGymCategory ? '🏋️ Phòng Gym' : '🏠 Tại Nhà';

  @override
  List<Object?> get props => [
    id,
    createdAt,
    imgUrl,
    titleEx,
    exerciseItems,
    classify,
  ];
}
