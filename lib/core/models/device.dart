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

  const Device({required this.id, required this.name, this.imgUrl});

  /// Tạo Device từ JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Device',
      imgUrl: json['img_url']?.toString(),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'img_url': imgUrl};
  }

  @override
  List<Object?> get props => [id, name, imgUrl];
}
