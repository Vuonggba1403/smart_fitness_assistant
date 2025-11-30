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
class ExerciseItem {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final List<String> muscleGroups;
  final List<String> devices;
  final String categoryId;

  ExerciseItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.muscleGroups,
    required this.devices,
    required this.categoryId,
  });

  /// Tạo ExerciseItem từ JSON/Map
  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    // Parse muscle groups từ string có dấu phẩy
    final muscleGroupStr = json['muscle_group']?.toString() ?? '';
    final muscleGroups = muscleGroupStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Parse devices từ string có dấu phẩy
    final deviceStr = json['device']?.toString() ?? '';
    final devices = deviceStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

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

  /// Convert ExerciseItem sang JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img_url': imageUrl,
      'des': description,
      'muscle_group': muscleGroups.join(', '),
      'device': devices.join(', '),
      'for_cate': categoryId,
    };
  }

  /// Kiểm tra có thiết bị hay không
  bool get hasEquipment => devices.isNotEmpty;

  /// Lấy string muscle groups đã join
  String get muscleGroupsString => muscleGroups.join(', ');

  /// Lấy string devices đã join
  String get devicesString => devices.join(', ');

  /// Copy với một số field thay đổi
  ExerciseItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    List<String>? muscleGroups,
    List<String>? devices,
    String? categoryId,
  }) {
    return ExerciseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      devices: devices ?? this.devices,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
