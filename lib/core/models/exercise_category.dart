import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

class ExerciseCategory extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? imgUrl;
  final String? titleEx;
  final String? titleExEn;
  final String? titleExVi;
  final List<dynamic>? exerciseItems;
  final String? classify;

  const ExerciseCategory({
    this.id,
    this.createdAt,
    this.imgUrl,
    this.titleEx,
    this.titleExEn,
    this.titleExVi,
    this.exerciseItems,
    this.classify,
  });

  /// Lấy title theo locale hiện tại
  String get localizedTitleEx {
    final locale = Get.locale?.languageCode ?? 'vi';
    if (locale == 'en' && titleExEn != null) return titleExEn!;
    if (locale == 'vi' && titleExVi != null) return titleExVi!;
    return titleEx ?? 'Workout';
  }

  /// Tạo ExerciseCategory từ JSON/Map
  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imgUrl: json['img_url'] as String?,
      titleEx:
          json['title_ex'] as String?, // Cột 'title_ex' chính là tiếng Việt
      titleExEn:
          json['title_ex_en']
              as String?, // Cột 'title_ex_en' chính là tiếng Anh
      titleExVi:
          json['title_ex'] as String?, // Cột 'title_ex' chính là tiếng Việt
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
    String? titleExEn,
    String? titleExVi,
    List<dynamic>? exerciseItems,
    String? classify,
  }) {
    return ExerciseCategory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      imgUrl: imgUrl ?? this.imgUrl,
      titleEx: titleEx ?? this.titleEx,
      titleExEn: titleExEn ?? this.titleExEn,
      titleExVi: titleExVi ?? this.titleExVi,
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
    titleExEn,
    titleExVi,
    exerciseItems,
    classify,
  ];
}
