import 'package:equatable/equatable.dart';
import 'device.dart'; // ✅ Đổi từ device_models.dart

/// Model đại diện cho một bài tập cụ thể (Exercise Item)
///
/// Chứa thông tin:
/// - id: ID unique của exercise
/// - title: Tên bài tập
/// - imageUrl: URL hình ảnh
/// - description: Mô tả cách thực hiện
/// - muscleGroups: Danh sách nhóm cơ được tập
/// - devices: Danh sách thiết bị cần thiết
/// - categoryId: ID của category chứa exercise này
class ExerciseItem extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final List<String> muscleGroups;

  // ✅ Thay List<String> devices bằng List<Device>
  final List<Device> devices;

  final String categoryId;

  const ExerciseItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.muscleGroups,
    required this.devices,
    required this.categoryId,
  });

  /// Tạo ExerciseItem từ JSON với devices từ JOIN query
  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    // Parse muscle groups
    final muscleGroupStr = json['muscle_group']?.toString() ?? '';
    final muscleGroups = muscleGroupStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // ✅ Parse devices từ nested array (JOIN với bảng exercise_devices)
    List<Device> devices = [];
    if (json['devices'] is List) {
      final devicesJson = json['devices'] as List<dynamic>;
      devices = devicesJson
          .map(
            (deviceJson) => Device.fromJson(deviceJson as Map<String, dynamic>),
          )
          .toList();
    }

    return ExerciseItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Exercise',
      imageUrl: json['img_url']?.toString() ?? '',
      description: json['des']?.toString() ?? '',
      muscleGroups: muscleGroups,
      devices: devices,
      categoryId: json['for_cate']?.toString() ?? '',
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img_url': imageUrl,
      'des': description,
      'muscle_group': muscleGroups.join(', '),
      'devices': devices.map((d) => d.toJson()).toList(),
      'for_cate': categoryId,
    };
  }

  /// Kiểm tra có thiết bị hay không
  bool get hasEquipment => devices.isNotEmpty;

  /// Lấy string muscle groups
  String get muscleGroupsString => muscleGroups.join(', ');

  /// ✅ Lấy tên các devices
  String get devicesString => devices.map((d) => d.name).join(', ');

  /// ✅ Lấy device đầu tiên có ảnh (để hiển thị thumbnail)
  Device? get primaryDevice => devices.isNotEmpty ? devices.first : null;

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    description,
    muscleGroups,
    devices,
    categoryId,
  ];
}
