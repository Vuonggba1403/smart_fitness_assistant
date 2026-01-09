import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

/// Model đại diện cho một thiết bị tập luyện
///
/// Mỗi thiết bị có:
/// - id: UUID unique
/// - name: Tên thiết bị (VD: "Tạ Tay", "Ghế Nghiêng")
/// - nameEn: Tên thiết bị tiếng Anh
/// - imgUrl: URL hình ảnh thiết bị
/// - createdAt: Thời gian tạo
class Device extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? imgUrl;

  const Device({
    required this.id,
    required this.name,
    this.nameEn,
    this.imgUrl,
  });

  /// Get localized device name based on current locale
  String get localizedName {
    final locale = Get.locale?.languageCode;
    print('🌐 Device locale: $locale, name: $name, nameEn: $nameEn');
    if (locale == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return name;
  }

  /// Tạo Device từ JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Device',
      nameEn: json['name_en']?.toString(),
      imgUrl: json['img_url']?.toString(),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'name_en': nameEn, 'img_url': imgUrl};
  }

  @override
  List<Object?> get props => [id, name, nameEn, imgUrl];
}
