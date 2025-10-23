part of 'theme_cubit.dart';

@immutable
class ThemeState {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  /// Tạo state mới từ state hiện tại (pattern copyWith)
  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}
