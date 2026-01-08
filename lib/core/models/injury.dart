import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

class Injury {
  final String id;
  final String name;
  final String nameEn;
  final String category;
  final String severity; // 'common', 'moderate', 'severe'
  final String description;

  Injury({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.severity,
    required this.description,
  });

  // Lấy tên theo locale hiện tại
  String get localizedName {
    final locale = Get.locale?.languageCode ?? 'vi';
    return locale == 'en' ? nameEn : name;
  }

  // ✅ Lấy category theo locale hiện tại
  String get localizedCategory {
    final categoryMap = {
      'Lưng': LocaleKey.injuryCategoryBack,
      'Đầu gối': LocaleKey.injuryCategoryKnee,
      'Vai': LocaleKey.injuryCategoryShoulder,
      'Cổ tay': LocaleKey.injuryCategoryWrist,
      'Mắt cá chân': LocaleKey.injuryCategoryAnkle,
      'Cổ': LocaleKey.injuryCategoryNeck,
      'Khuỷu tay': LocaleKey.injuryCategoryElbow,
      'Hông': LocaleKey.injuryCategoryHip,
      'Bàn chân': LocaleKey.injuryCategoryFoot,
      'Chân': LocaleKey.injuryCategoryLeg,
      'Đùi': LocaleKey.injuryCategoryThigh,
      'Háng': LocaleKey.injuryCategoryGroin,
      'Ngực': LocaleKey.injuryCategoryChest,
    };

    final localeKey = categoryMap[category];
    return localeKey?.tr ?? category;
  }

  factory Injury.fromJson(Map<String, dynamic> json) {
    return Injury(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      category: json['category'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'category': category,
      'severity': severity,
      'description': description,
    };
  }

  /// Lấy màu theo mức độ nghiêm trọng
  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'common':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Lấy label cho severity theo locale
  static String getSeverityLabel(String severity) {
    final locale = Get.locale?.languageCode ?? 'vi';
    if (locale == 'en') {
      switch (severity) {
        case 'common':
          return 'Common';
        case 'moderate':
          return 'Moderate';
        case 'severe':
          return 'Severe';
        default:
          return 'Other';
      }
    }
    switch (severity) {
      case 'common':
        return 'Phổ biến';
      case 'moderate':
        return 'Trung bình';
      case 'severe':
        return 'Nghiêm trọng';
      default:
        return 'Khác';
    }
  }
}
