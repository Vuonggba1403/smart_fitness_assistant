import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class AppTheme {
  // 🌞 ---------------- LIGHT THEME ----------------
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0, // Bỏ đổ bóng
    ),

    colorScheme: ColorScheme.light(
      primary: TColor.primaryColor1, // Màu chủ đạo (nút, accent,...)
      secondary: TColor.secondaryColor1, // Màu phụ
    ),

    // 🧱 Card
    cardColor: Colors.white, // Màu nền cho các card, container
  );

  // 🌚 ---------------- DARK THEME ----------------
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0E0E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E0E0E), // AppBar trùng với nền
      foregroundColor: Colors.white, // Màu chữ và icon trắng
      elevation: 0,
    ),

    // 🎨 ColorScheme: hệ màu chính/phụ cho dark mode
    colorScheme: ColorScheme.dark(
      primary: TColor.primaryColor1,
      secondary: TColor.secondaryColor1,
    ),

    // 🧱 Card - Màu tối phù hợp dark mode
    cardColor: const Color(0xFF1A1A1A), // ✅ Thay thành màu tối gần đen
  );
  // 🎨 ---------------- GRADIENT HELPER ----------------
  static List<Color> gradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [TColor.secondaryColor1, TColor.secondaryColor2]
        : [TColor.primaryColor1, TColor.primaryColor2];
  }
}
