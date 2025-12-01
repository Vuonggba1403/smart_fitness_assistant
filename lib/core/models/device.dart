import 'package:equatable/equatable.dart';

/// Model đại diện cho một thiết bị tập luyện
///
/// Mỗi thiết bị có:
/// - id: UUID unique
/// - name: Tên thiết bị (VD: "Tạ Tay", "Ghế Nghiêng")
/// - imgUrl: URL hình ảnh thiết bị
/// - createdAt: Thời gian tạo
class Device extends Equatable {
  final String id;
  final String name;
  final String? imgUrl;
  final DateTime? createdAt;

  const Device({
    required this.id,
    required this.name,
    this.imgUrl,
    this.createdAt,
  });

  /// Tạo Device từ JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      imgUrl: json['img_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'img_url': imgUrl,
    'created_at': createdAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, imgUrl, createdAt];
}
