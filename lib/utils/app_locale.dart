import 'package:chat_bot/utils/utility.dart';
import 'package:flutter/material.dart';

/// Locale / text-direction driven by [Utility.getLanguage()].
///
/// In package mode, routes are pushed on the **host** navigator, so they inherit
/// the host app's LTR Directionality. Always wrap package screens with [wrap]
/// (or push via [materialRoute]) so RTL follows `Utility.getLanguage()`.
class AppLocale {
  AppLocale._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  /// Normalized language code from [Utility.getLanguage] (`en` / `ar`).
  static String get languageCode {
    final raw = Utility.getLanguage().trim().toLowerCase();
    if (raw.isEmpty) return 'en';
    if (raw.startsWith('ar')) return 'ar';
    if (raw.startsWith('en')) return 'en';
    return raw.split(RegExp(r'[-_]')).first;
  }

  static Locale get locale => Locale(languageCode);

  static bool get isRtl => isRtlLanguageCode(languageCode);

  static TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  static bool isRtlLanguageCode(String code) {
    switch (code.toLowerCase().split(RegExp(r'[-_]')).first) {
      case 'ar':
      case 'he':
      case 'fa':
      case 'ur':
        return true;
      default:
        return false;
    }
  }

  static bool isRtlLocale(Locale locale) =>
      isRtlLanguageCode(locale.languageCode);

  static TextDirection textDirectionOf(Locale locale) =>
      isRtlLocale(locale) ? TextDirection.rtl : TextDirection.ltr;

  /// Force layout direction from [Utility.getLanguage] for this subtree.
  /// Use at the root of every package screen / sheet so host LTR cannot leak in.
  static Widget wrap(Widget child) {
    return Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  /// [MaterialPageRoute] that applies [wrap] so RTL works in package mode.
  static MaterialPageRoute<T> materialRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      builder: (context) => wrap(builder(context)),
    );
  }

  /// [PageRouteBuilder] that applies [wrap] so RTL works in package mode.
  static PageRouteBuilder<T> pageRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration transitionDuration = Duration.zero,
    Duration reverseTransitionDuration = Duration.zero,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) =>
          wrap(builder(context)),
    );
  }
}
