import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'lang_en.dart';
import 'lang_vi.dart';

/// Quản lý đa ngôn ngữ cho ứng dụng
class TranslationManager extends Translations {
  // Ngôn ngữ mặc định
  static const Locale fallbackLocaleVN = Locale('vi', 'VI');
  static const Locale fallbackLocaleUS = Locale('en', 'US');

  // Danh sách ngôn ngữ hỗ trợ
  static final List<Locale> supportedLocales = [
    fallbackLocaleUS,
    fallbackLocaleVN,
  ];

  // Locale hiện tại
  late Locale _locale;
  Locale get locale => _locale;

  TranslationManager() {
    _initLocale();
  }

  /// Lấy locale từ cache hoặc mặc định
  void _initLocale() {
    final cached = AppShared.getLanguageCodeSync();
    _locale = supportedLocales.firstWhere(
      (e) => e.languageCode == cached,
      orElse: () => fallbackLocaleVN,
    );
    AppShared.setLanguageCode(_locale.languageCode);
  }

  /// Map ngôn ngữ
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'vi_VI': viVN};

  /// Cập nhật locale hiện tại
  Future<void> updateLocale(Locale locale) async {
    _locale = locale;
    Get.updateLocale(locale);
    await AppShared.setLanguageCode(locale.languageCode);
  }

  /// Chuyển đổi Anh ↔ Việt
  Future<void> toggleLanguage() async {
    final isVN = _locale.languageCode == 'vi';
    await updateLocale(isVN ? fallbackLocaleUS : fallbackLocaleVN);
  }

  /// Trả locale từ code
  Locale getLocale(String code) =>
      code == 'vi' ? fallbackLocaleVN : fallbackLocaleUS;
}
