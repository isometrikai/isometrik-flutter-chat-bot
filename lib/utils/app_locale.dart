import 'package:flutter/material.dart';

/// Locale / text-direction helpers aligned with EasyLocalization locales.
class AppLocale {
  AppLocale._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static bool isRtlLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
      case 'he':
      case 'fa':
      case 'ur':
        return true;
      default:
        return false;
    }
  }

  static TextDirection textDirectionOf(Locale locale) =>
      isRtlLocale(locale) ? TextDirection.rtl : TextDirection.ltr;
}
