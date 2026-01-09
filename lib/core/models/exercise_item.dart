import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'device.dart';

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
  final String? titleEn;
  final String imageUrl;
  final String description;
  final String? descriptionEn;
  final List<String> muscleGroups;
  final List<String>? muscleGroupsEn;
  final List<Device> devices;
  final String categoryId;
  final String? imgMuscleGroups;

  const ExerciseItem({
    required this.id,
    required this.title,
    this.titleEn,
    required this.imageUrl,
    required this.description,
    this.descriptionEn,
    required this.muscleGroups,
    this.muscleGroupsEn,
    required this.devices,
    required this.categoryId,
    this.imgMuscleGroups,
  });

  /// Get localized title based on current locale
  String get localizedTitle {
    final locale = Get.locale?.languageCode;
    print('🌐 ExerciseItem locale: $locale, title: $title, titleEn: $titleEn');
    if (locale == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    return title;
  }

  /// Get localized description based on current locale
  String get localizedDescription {
    final locale = Get.locale?.languageCode;
    if (locale == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) {
      return descriptionEn!;
    }
    return description;
  }

  /// Get localized muscle groups based on current locale
  List<String> get localizedMuscleGroups {
    final locale = Get.locale?.languageCode;
    if (locale == 'en' &&
        muscleGroupsEn != null &&
        muscleGroupsEn!.isNotEmpty) {
      return muscleGroupsEn!;
    }
    return muscleGroups;
  }

  /// Tạo ExerciseItem từ JSON với devices từ JOIN query
  /// ✅ Fallback: Nếu không có devices từ JOIN, parse từ cột 'device' (string)
  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    // Parse muscle groups (Vietnamese)
    final muscleGroupStr = json['muscle_group']?.toString() ?? '';
    final muscleGroups = muscleGroupStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Parse muscle groups (English)
    final muscleGroupEnStr = json['muscle_group_en']?.toString() ?? '';
    final muscleGroupsEn = muscleGroupEnStr.isNotEmpty
        ? muscleGroupEnStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : null;

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
      titleEn: json['title_en']?.toString(),
      imageUrl: json['img_url']?.toString() ?? '',
      description: json['des']?.toString() ?? '',
      descriptionEn: json['des_en']?.toString(),
      muscleGroups: muscleGroups,
      muscleGroupsEn: muscleGroupsEn,
      devices: devices,
      categoryId: json['for_cate']?.toString() ?? '',
      imgMuscleGroups: json['img_musclegroups']
          ?.toString(), // ✅ Sửa lại: img_musclegroups (KHÔNG có _ giữa muscle và groups)
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
      'img_musclegroups': imgMuscleGroups,
    };
  }

  /// Kiểm tra có thiết bị hay không
  bool get hasEquipment => devices.isNotEmpty;

  /// Lấy string muscle groups (localized)
  String get muscleGroupsString => localizedMuscleGroups.join(', ');

  /// ✅ Lấy tên các devices (localized)
  String get devicesString => devices.map((d) => d.localizedName).join(', ');

  /// ✅ Lấy device đầu tiên có ảnh (để hiển thị thumbnail)
  Device? get primaryDevice => devices.isNotEmpty ? devices.first : null;

  @override
  List<Object?> get props => [
    id,
    title,
    titleEn,
    imageUrl,
    description,
    descriptionEn,
    muscleGroups,
    muscleGroupsEn,
    devices,
    categoryId,
    imgMuscleGroups,
  ];
}
