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
  final List<Device> devices;
  final String categoryId;
  final String? imgMuscleGroups; // ✅ Thêm trường mới
  final int? number; // ✅ Thêm trường number

  const ExerciseItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.muscleGroups,
    required this.devices,
    required this.categoryId,
    this.imgMuscleGroups, // ✅ Thêm vào constructor
    this.number, // ✅ Thêm vào constructor
  });

  /// Tạo ExerciseItem từ JSON với devices từ JOIN query
  /// ✅ Fallback: Nếu không có devices từ JOIN, parse từ cột 'device' (string)
  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    // Parse muscle groups
    final muscleGroupStr = json['muscle_group']?.toString() ?? '';
    final muscleGroups = muscleGroupStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // ✅ Parse devices - Ưu tiên JOIN, fallback về string
    List<Device> devices = [];

    // Cách 1: Từ nested array (JOIN với bảng exercise_devices)
    if (json['devices'] is List && (json['devices'] as List).isNotEmpty) {
      final devicesJson = json['devices'] as List<dynamic>;

      // Lọc unique theo tên (case-insensitive)
      final Map<String, Device> uniqueDevicesMap = {};

      for (var deviceJson in devicesJson) {
        final device = Device.fromJson(deviceJson as Map<String, dynamic>);
        final keyLower = device.name.toLowerCase();

        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = device;
        }
      }

      devices = uniqueDevicesMap.values.toList();
    }
    // Cách 2: FALLBACK - Parse từ cột 'device' (string) nếu không có JOIN data
    else if (json['device'] != null &&
        json['device'].toString().trim().isNotEmpty) {
      final deviceStr = json['device']?.toString() ?? '';
      final deviceNames = deviceStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);

      // Lọc unique và tạo Device objects (không có ảnh)
      final Map<String, Device> uniqueDevicesMap = {};

      for (var name in deviceNames) {
        final keyLower = name.toLowerCase();
        if (!uniqueDevicesMap.containsKey(keyLower)) {
          uniqueDevicesMap[keyLower] = Device(
            id: keyLower.replaceAll(' ', '_'), // Tạo id tạm từ tên
            name: name,
            imgUrl: null, // Không có ảnh khi parse từ string
          );
        }
      }

      devices = uniqueDevicesMap.values.toList();
    }

    return ExerciseItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Exercise',
      imageUrl: json['img_url']?.toString() ?? '',
      description: json['des']?.toString() ?? '',
      muscleGroups: muscleGroups,
      devices: devices,
      categoryId: json['for_cate']?.toString() ?? '',
      imgMuscleGroups: json['img_musclegroups']
          ?.toString(), // ✅ Sửa lại: img_musclegroups (KHÔNG có _ giữa muscle và groups)
      number: json['number'] as int?, // ✅ Parse number từ DB
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
      'img_musclegroups': imgMuscleGroups, // ✅ Sửa lại: img_musclegroups
      'number': number, // ✅ Thêm vào JSON
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
    imgMuscleGroups, // ✅ Thêm vào props
    number, // ✅ Thêm vào props
  ];
}
