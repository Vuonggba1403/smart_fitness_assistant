import 'package:get/get.dart';

class ActivityLevel {
  final String id;
  final String title;
  final String description;
  final String? titleEn;
  final String? titleVi;
  final String? descriptionEn;
  final String? descriptionVi;
  final double activityFactor;
  final int number;
  final String? icon;

  ActivityLevel({
    required this.id,
    required this.title,
    required this.description,
    this.titleEn,
    this.titleVi,
    this.descriptionEn,
    this.descriptionVi,
    required this.activityFactor,
    required this.number,
    this.icon,
  });

  // Lấy title theo locale hiện tại
  String get localizedTitle {
    final locale = Get.locale?.languageCode ?? 'vi';
    if (locale == 'en' && titleEn != null) return titleEn!;
    if (locale == 'vi' && titleVi != null) return titleVi!;
    return title;
  }

  // Lấy description theo locale hiện tại
  String get localizedDescription {
    final locale = Get.locale?.languageCode ?? 'vi';
    if (locale == 'en' && descriptionEn != null) return descriptionEn!;
    if (locale == 'vi' && descriptionVi != null) return descriptionVi!;
    return description;
  }

  factory ActivityLevel.fromJson(Map<String, dynamic> json) {
    return ActivityLevel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      titleEn: json['title_en'] as String?,
      titleVi: json['title'] as String?, // Cột 'title' chính là tiếng Việt
      descriptionEn: json['description_en'] as String?,
      descriptionVi:
          json['description']
              as String?, // Cột 'description' chính là tiếng Việt
      activityFactor: (json['activity_factor'] as num).toDouble(),
      number: json['number'] as int,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'activity_factor': activityFactor,
      'number': number,
      'icon': icon,
    };
  }
}
