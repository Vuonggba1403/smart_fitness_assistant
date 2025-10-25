import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: TColor.white,
      foregroundColor: TColor.black,
      elevation: 0,
    ),

    colorScheme: ColorScheme.light(
      primary: TColor.primaryColor1, // Màu chủ đạo (nút, accent,...)
      secondary: TColor.secondaryColor1, // Màu phụ
    ),

    cardColor: TColor.white,
    shadowColor: Colors.black12,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0E0E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0E0E0E), // AppBar trùng với nền
      foregroundColor: TColor.white, // Màu chữ và icon trắng
      elevation: 0,
    ),

    // 🎨 ColorScheme: hệ màu chính/phụ cho dark mode
    colorScheme: ColorScheme.dark(
      primary: TColor.primaryColor1,
      secondary: TColor.secondaryColor1,
    ),

    cardColor: const Color(0xFF1A1A1A),
    shadowColor: Colors.black54,
  );

  static List<Color> gradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [TColor.secondaryColor1, TColor.secondaryColor2]
        : [TColor.primaryColor1, TColor.primaryColor2];
  }

  static List<Color> gradientColors1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [
            TColor.secondaryColor2.withOpacity(0.3),
            TColor.secondaryColor1.withOpacity(0.3),
          ]
        : [
            TColor.primaryColor2.withOpacity(0.3),
            TColor.primaryColor1.withOpacity(0.3),
          ];
  }
}

extension CustomDecorations on ThemeData {
  BoxDecoration get textFieldDecoration => BoxDecoration(
    color: brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : TColor.lightGray,
    borderRadius: BorderRadius.circular(15),
  );
}
