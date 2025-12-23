import 'package:flutter/material.dart';

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

  /// Lấy label tiếng Việt cho severity
  static String getSeverityLabel(String severity) {
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
