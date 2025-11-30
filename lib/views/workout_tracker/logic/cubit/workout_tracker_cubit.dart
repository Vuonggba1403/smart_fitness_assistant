import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'workout_tracker_state.dart';

/// Cubit quản lý trạng thái của màn hình Workout Tracker
class WorkoutTrackerCubit extends Cubit<WorkoutTrackerState> {
  WorkoutTrackerCubit() : super(WorkoutTrackerInitial());

  /// Map lưu trữ trạng thái toggle của các workout
  final Map<int, bool> _toggleStates = {};

  /// Instance của Supabase client để gọi API
  final _supabase = Supabase.instance.client;

  /// Lấy trạng thái toggle của workout tại index
  /// Trả về false nếu chưa có trạng thái
  bool getToggleState(int index) => _toggleStates[index] ?? false;

  /// Cập nhật trạng thái toggle của workout
  /// [index] - Vị trí của workout
  /// [value] - Giá trị toggle mới (true/false)
  void toggleWorkout(int index, bool value) {
    _toggleStates[index] = value;
    emit(WorkoutToggleChanged(Map.from(_toggleStates)));
  }

  /// Lấy danh sách các danh mục bài tập từ Supabase
  ///
  /// Thực hiện:
  /// 1. Emit trạng thái Loading
  /// 2. Query dữ liệu từ bảng 'exercise_categories' với các cột:
  ///    - img_url: URL hình ảnh
  ///    - title_ex: Tên bài tập
  /// 3. Thêm dữ liệu hardcode cho exercise_count và duration_mins
  /// 4. Emit trạng thái Loaded với dữ liệu hoặc Error nếu có lỗi
  Future<void> fetchExerciseCategories() async {
    try {
      // Emit trạng thái đang tải
      emit(ExerciseCategoriesLoading());

      // Gọi API Supabase để lấy dữ liệu (chỉ img_url và title_ex)
      final response = await _supabase
          .from('exercise_categories')
          .select('img_url, title_ex');

      // Dữ liệu hardcode cho exercise_count và duration_mins
      final hardcodedData = [
        {'exercise_count': 11, 'duration_mins': 32},
        {'exercise_count': 12, 'duration_mins': 40},
        {'exercise_count': 14, 'duration_mins': 20},
      ];

      // Chuyển đổi response thành List<Map> và merge với dữ liệu hardcode
      final categories = List<Map<String, dynamic>>.from(response)
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;

            // Lấy dữ liệu hardcode tương ứng hoặc dữ liệu mặc định
            final hardcoded = index < hardcodedData.length
                ? hardcodedData[index]
                : {'exercise_count': 10, 'duration_mins': 30};

            return {...item, ...hardcoded};
          })
          .toList();

      // Emit trạng thái đã tải thành công với dữ liệu
      emit(ExerciseCategoriesLoaded(categories));
    } catch (e) {
      // Emit trạng thái lỗi với message
      emit(ExerciseCategoriesError(e.toString()));
    }
  }

  /// Lấy exercise items theo category ID
  ///
  /// [categoryId] - ID của category để lọc
  /// Fetch 2 loại dữ liệu:
  /// 1. Devices - Items có device field (thiết bị cần thiết) - hiển thị ở "You'll Need"
  /// 2. Exercises - Tất cả items (bài tập) - hiển thị ở "Exercises"
  Future<void> fetchExerciseItems(String categoryId) async {
    try {
      emit(ExerciseItemsLoading());

      // Lấy tất cả items theo category từ bảng exercise_items
      final response = await _supabase
          .from('exercise_items')
          .select('id, title, img_url, des, muscle_group, device')
          .eq('for_cate', categoryId);

      final items = List<Map<String, dynamic>>.from(response);

      // Tách devices: Chỉ lấy items có device không null và không rỗng
      // Đây là thiết bị cần thiết cho workout
      final devices = items
          .where(
            (item) =>
                item['device'] != null &&
                item['device'].toString().trim().isNotEmpty,
          )
          .toList();

      // Exercises: Tất cả items đều là bài tập
      final exercises = items;

      emit(ExerciseItemsLoaded(devices, exercises));
    } catch (e) {
      emit(ExerciseItemsError(e.toString()));
    }
  }

  /// Stream exercise items theo category ID với realtime updates
  ///
  /// [categoryId] - ID của category để lọc
  /// Returns Stream với devices và exercises được update realtime
  Stream<Map<String, List<Map<String, dynamic>>>> streamExerciseItems(
    String categoryId,
  ) {
    return _supabase
        .from('exercise_items')
        .stream(primaryKey: ['id'])
        .eq('for_cate', categoryId)
        .map((data) {
          final items = List<Map<String, dynamic>>.from(data);

          // Tách devices: items có device không null và không rỗng
          final devices = items
              .where(
                (item) =>
                    item['device'] != null &&
                    item['device'].toString().trim().isNotEmpty,
              )
              .toList();

          // Exercises: tất cả items
          final exercises = items;

          return {'devices': devices, 'exercises': exercises};
        });
  }

  /// Stream exercise categories với exercise_items nested
  /// Returns Stream realtime cho toàn bộ categories và items
  Stream<List<Map<String, dynamic>>> streamExerciseCategories() {
    return _supabase
        .from('exercise_categories')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((categories) {
          final hardcodedData = [
            {'exercise_count': 11, 'duration_mins': 32},
            {'exercise_count': 12, 'duration_mins': 40},
            {'exercise_count': 14, 'duration_mins': 20},
          ];

          return List<Map<String, dynamic>>.from(
            categories,
          ).asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final hardcoded = index < hardcodedData.length
                ? hardcodedData[index]
                : {'exercise_count': 10, 'duration_mins': 30};

            return {...item, ...hardcoded};
          }).toList();
        });
  }
}
