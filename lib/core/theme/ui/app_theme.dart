import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class AppTheme {
  // 🌞 ---------------- LIGHT THEME ----------------
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // Nền AppBar trắng
      foregroundColor: Colors.black, // Màu icon & chữ trong AppBar
      elevation: 0, // Bỏ đổ bóng
    ),

    // 🎨 ColorScheme: chứa các màu chính và phụ của ứng dụng
    colorScheme: ColorScheme.light(
      primary: TColor.primaryColor1, // Màu chủ đạo (nút, accent,...)
      secondary: TColor.secondaryColor1, // Màu phụ
    ),

    // 🧱 Card
    cardColor: Colors.white, // Màu nền cho các card, container
    shadowColor: Colors.black12, // Màu bóng đổ nhẹ khi sáng
    // 🔤 Text
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black), // Màu chữ chính
      bodySmall: TextStyle(color: Colors.black54), // Màu chữ phụ, nhạt hơn
    ),
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
    shadowColor: Colors.black54, // Bóng đổ mạnh hơn để nổi khối
    // 🔤 Text
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white), // Màu chữ chính
      bodySmall: TextStyle(color: Colors.white70), // Màu chữ phụ nhạt hơn
    ),
  );
}
