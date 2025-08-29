import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/services/auth_service.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/utils/api_result.dart';

import '../data/model/greeting_response.dart';

class ApiService {
  static Future<void> initialize() async {
    await AuthService.instance.initialize();
    await ChatApiServices.instance.initialize();
  }

  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    required String stripePublishableKey,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    // Configure AuthService (legacy support)
    AuthService.instance.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      stripePublishableKey: stripePublishableKey,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );

    // Configure ComprehensiveApiService (new system)
    ChatApiServices.instance.configure(
      chatBotId: chatBotId,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      stripePublishableKey: stripePublishableKey,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );
  }

}


