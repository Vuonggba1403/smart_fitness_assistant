import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  /// Khởi tạo với mặc định (isDarkMode = false).
  /// Sau đó _loadTheme sẽ đọc prefs và emit lại nếu có saved value.
  ThemeCubit() : super(const ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  /// Load giá trị isDarkMode từ SharedPreferences.
  /// Nếu chưa có, sử dụng giá trị mặc định (false).
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    // Emit state mới (nếu khác hoặc giống thì vẫn emit, nhưng không sao)
    emit(state.copyWith(isDarkMode: isDark));
  }

  /// Thay đổi theme: lưu vào SharedPreferences và emit state mới.
  /// - isDark: true => bật dark mode; false => tắt.
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  /// Trả về ThemeData hiện tại (tiện nếu cần lấy trực tiếp)
  ThemeData get currentTheme =>
      state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
}
