import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static late SharedPreferences _prefs;

  /// Khởi tạo SharedPreferences (gọi trong main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
