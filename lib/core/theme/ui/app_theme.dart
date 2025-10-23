import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

/// AppTheme chuẩn hoá màu, gradient, text styles cho toàn app.
/// Widget chỉ cần dùng Theme.of(context) để lấy màu, gradient, textStyle.
class AppTheme {
  // ==================== LIGHT THEME ====================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: TColor.white,
    appBarTheme: AppBarTheme(
      backgroundColor: TColor.white,
      foregroundColor: TColor.black,
      elevation: 0,
    ),
    colorScheme: ColorScheme.light(
      primary: TColor.primaryColor1,
      secondary: TColor.secondaryColor1,
    ),
    cardColor: TColor.white,
    bottomAppBarTheme: BottomAppBarThemeData(color: TColor.white),
    textTheme: _lightTextTheme,
    iconTheme: IconThemeData(color: TColor.black),
  );

  // ==================== DARK THEME ====================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TColor.black,
    appBarTheme: AppBarTheme(
      backgroundColor: TColor.black,
      foregroundColor: TColor.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.dark(
      primary: TColor.primaryColor1,
      secondary: TColor.secondaryColor1,
    ),
    cardColor: TColor.black,
    bottomAppBarTheme: BottomAppBarThemeData(color: TColor.black),
    textTheme: _darkTextTheme,
    iconTheme: IconThemeData(color: TColor.white),
  );

  // ==================== GRADIENTS ====================
  /// Sử dụng: Theme.of(context).primaryGradient
  static List<Color> primaryGradient({bool isDark = false}) => isDark
      ? [TColor.secondaryColor1, TColor.secondaryColor2]
      : [TColor.primaryColor1, TColor.primaryColor2];

  static List<Color> secondaryGradient({bool isDark = false}) => isDark
      ? [TColor.primaryColor1, TColor.primaryColor2]
      : [TColor.secondaryColor1, TColor.secondaryColor2];

  // ==================== TEXT THEME ====================
  static final TextTheme _lightTextTheme = TextTheme(
    bodyMedium: TextStyle(color: TColor.black),
    bodySmall: TextStyle(color: TColor.gray),
    titleMedium: TextStyle(color: TColor.black, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: TColor.gray, fontSize: 12),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    bodyMedium: TextStyle(color: TColor.white),
    bodySmall: TextStyle(color: TColor.gray),
    titleMedium: TextStyle(color: TColor.white, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: TColor.gray, fontSize: 12),
  );
}

// ==================== EXTENSION ====================
// Giúp gọi trực tiếp từ context
extension ThemeGradientExtension on BuildContext {
  List<Color> get primaryGradient =>
      Theme.of(this).brightness == Brightness.dark
      ? AppTheme.primaryGradient(isDark: true)
      : AppTheme.primaryGradient(isDark: false);

  List<Color> get secondaryGradient =>
      Theme.of(this).brightness == Brightness.dark
      ? AppTheme.secondaryGradient(isDark: true)
      : AppTheme.secondaryGradient(isDark: false);
}
