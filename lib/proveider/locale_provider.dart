import 'package:easy_localization/easy_localization.dart' show EasyLocalization, BuildContextEasyLocalizationExtension;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class LocaleProvider extends ChangeNotifier {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   Locale _locale = const Locale('ar', 'SA');

//   LocaleProvider() {
//     _loadLocale();
//   }

//   Locale get locale => _locale;

//   bool get isArabic => _locale.languageCode == 'ar';

//   TextDirection get textDirection =>
//       isArabic ? TextDirection.rtl : TextDirection.ltr;

// Future<void> switchLocale() async {
//   try {
//     _locale = isArabic ? const Locale('en', 'US') : const Locale('ar', 'SA');
//     print('Saving locale: ${_locale.languageCode}');
//     await _storage.write(key: 'locale', value: _locale.languageCode);
//     notifyListeners();
//   } catch (e) {
//     print('Error saving locale: $e');
//   }
// }

// Future<void> _loadLocale() async {
//   try {
//     String? savedLocale = await _storage.read(key: 'locale');
//     if (savedLocale != null) {
//       _locale = savedLocale == 'ar'
//           ? const Locale('ar', 'SA')
//           : const Locale('en', 'US');
//       notifyListeners();
//     }
//   } catch (e) {
//     print('Error reading locale from secure storage: $e');
//   }
// }
// }

class LocaleProvider extends ChangeNotifier {
  TextDirection _textDirection = TextDirection.rtl;

  TextDirection get textDirection => _textDirection;

  LocaleProvider(BuildContext context) {
    _syncWithContext(context);
  }

  Future<void> _syncWithContext(BuildContext context) async {
    String lang = 'ar';
    try {
      lang = context.locale.languageCode;
    } catch (_) {}
    _textDirection = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    notifyListeners();
  }

  Future<void> changeDirection(String langCode) async {
    _textDirection = langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);

    notifyListeners();
  }
}
