import 'package:get/get.dart';

class Meal {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final String? imageUrl;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? fiberG;
  final double? cholesterolMg;
  final int servingSizeG;
  final bool isVerified;
  final String? category;
  final String? barcode;

  Meal({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.imageUrl,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG,
    this.cholesterolMg,
    this.servingSizeG = 100,
    this.isVerified = false,
    this.category,
    this.barcode,
  });

  /// Localized getters
  String get localizedName {
    final locale = Get.locale?.languageCode;
    if (locale == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return name;
  }

  String? get localizedDescription {
    final locale = Get.locale?.languageCode;
    if (locale == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) {
      return descriptionEn;
    }
    return description;
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      imageUrl: json['image_url'] as String?,
      calories: json['calories'] as int,
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
      fiberG: json['fiber_g'] != null
          ? (json['fiber_g'] as num).toDouble()
          : null,
      cholesterolMg: json['cholesterol_mg'] != null
          ? (json['cholesterol_mg'] as num).toDouble()
          : null,
      servingSizeG: json['serving_size_g'] as int? ?? 100,
      isVerified: json['is_verified'] as bool? ?? false,
      category: json['category'] as String?,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'cholesterol_mg': cholesterolMg,
      'serving_size_g': servingSizeG,
      'is_verified': isVerified,
      'category': category,
      'barcode': barcode,
    };
  }
}
