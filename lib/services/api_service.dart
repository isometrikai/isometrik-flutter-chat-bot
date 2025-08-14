import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/services/auth_service.dart';

import '../data/model/greeting_response.dart';

class ApiService {
  static Future<void> initialize() => AuthService.instance.initialize();

  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    AuthService.instance.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );
  }

  static Future<MyGPTsResponse?> getChatbotData() =>
      AuthService.instance.getChatbotData();

  static Future<GreetingResponse?> getInitialOptionData() =>
      AuthService.instance.getInitialOptionData();

  static Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) =>
      AuthService.instance.sendChatMessage(
        message: message,
        agentId: agentId,
        fingerPrintId: fingerPrintId,
        sessionId: sessionId,
        isLoggedIn: isLoggedIn,
        longitude: longitude,
        latitude: latitude,
      );

  static bool get isProduction => AuthService.instance.isProduction;
}


