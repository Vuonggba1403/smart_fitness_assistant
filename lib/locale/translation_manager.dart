import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'lang_en.dart';
import 'lang_vi.dart';

class TranslationManager extends Translations {
  late Locale _locale;

  // Get current locale
  Locale get locale => _locale;

  // Constructor
  TranslationManager() {
    _initLanguageCodeFromCached();
  }

  /// Convert string to Locale
  Locale? _convertStringToLocale(String languageCode) => appLocales
      .firstWhereOrNull((element) => element.languageCode == languageCode);

  /// Init language code when load app
  void _initLanguageCodeFromCached() {
    String? cachedLanguage = AppShared.getLanguageCodeSync();

    if (cachedLanguage == null) {
      _locale = fallbackLocaleVN;
      AppShared.setLanguageCode(_locale.languageCode);
    } else {
      _locale = _convertStringToLocale(cachedLanguage) ?? fallbackLocaleVN;
    }
  }

  static Locale fallbackLocaleVN = const Locale('vi', 'VI');
  static Locale fallbackLocaleUS = const Locale('en', 'US');

  List<Locale> appLocales = [fallbackLocaleUS, fallbackLocaleVN];

  /// Support translate language
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'vi_VI': viVN};

  /// Update locale to GetX and AppShared
  Future<void> updateLocale(Locale locale) async {
    Get.updateLocale(locale);
    await AppShared.setLanguageCode(locale.languageCode);
    _locale = locale;
  }

  /// Toggle language
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'vi'
        ? fallbackLocaleUS
        : fallbackLocaleVN;
    await updateLocale(newLocale);
  }

  Locale getLocale(String languageCode) {
    return languageCode == 'vi' ? fallbackLocaleVN : fallbackLocaleUS;
  }
}
