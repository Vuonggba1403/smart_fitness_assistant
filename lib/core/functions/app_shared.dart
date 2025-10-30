import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static late SharedPreferences _prefs;
  static const String _languageKey = 'language_code';

  /// Khởi tạo SharedPreferences (gọi trong main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Lấy mã ngôn ngữ đã lưu (Sync - không cần await)
  static String? getLanguageCodeSync() {
    return _prefs.getString(_languageKey);
  }

  /// Lấy mã ngôn ngữ đã lưu (Async)
  static Future<String> getLanguageCode() async {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  /// Lưu mã ngôn ngữ
  static Future<void> setLanguageCode(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }
}
