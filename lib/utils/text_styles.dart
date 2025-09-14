import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Utility class for consistent text styles across the app
/// This ensures all text uses Plus Jakarta Sans font
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  /// Get heading style with Plus Jakarta Sans
  static TextStyle heading({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return AppTheme.getHeadingStyle(
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
    ).copyWith(
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Get body text style with Plus Jakarta Sans
  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return AppTheme.getBodyStyle(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
    ).copyWith(
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Get custom text style with Plus Jakarta Sans
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return AppTheme.getTextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    ).copyWith(
      fontStyle: fontStyle,
    );
  }

  // Predefined common styles
  static TextStyle get title => heading(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle get subtitle => body(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get bodyText => body(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get caption => body(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle get button => body(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get label => body(fontSize: 12, fontWeight: FontWeight.w500);

  // Chat specific styles
  static TextStyle get chatMessage => body(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get chatInput => body(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Restaurant screen styles
  static TextStyle get restaurantTitle => heading(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get restaurantSubtitle => body(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get restaurantDescription => body(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Product customization styles
  static TextStyle get productTitle => heading(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get productPrice => body(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get addonTitle => body(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get addonDescription => body(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Cart styles
  static TextStyle get cartItemTitle => body(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get cartItemPrice => body(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get cartTotal => heading(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // Launch screen styles
  static TextStyle get launchTitle => heading(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get launchSubtitle => body(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get launchWeather => body(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  ).copyWith(
    fontStyle: FontStyle.italic,
  );

  // Common color styles
  static TextStyle get primaryText => body(color: const Color(0xFF242424));
  static TextStyle get secondaryText => body(color: const Color(0xFF6E4185));
  static TextStyle get accentText => body(color: const Color(0xFF171212));
  static TextStyle get hintText => body(color: Colors.grey);
  static TextStyle get errorText => body(color: Colors.red);
  static TextStyle get successText => body(color: Colors.green);
}
