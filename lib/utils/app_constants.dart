import 'package:chat_bot/services/api_service.dart';
import 'package:flutter/material.dart';

/// Centralized constants for the application
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Base URLs
  static const String baseUrl = 'https://service-apis.isometrik.io';
  
  /// Chat base URL - dynamically returns staging or production URL based on isProduction flag
  /// Staging: https://easyagentapi.eazylife-online.com
  /// Production: https://easyagentapi-live.eazylife-online.com
  static String get chatBaseUrl {
    return ApiService.isProduction
        ? 'https://easyagentapi-live.eazylife-online.com'
        : 'https://easyagentapi.eazylife-online.com';
  }

  // Theme Colors
  /// Primary app theme color - iOS Blue (#007AFF)
  static const Color appThemeColor = Color(0xFF007AFF);
  
}
