library chat_bot;

import 'package:flutter/material.dart';
import 'view/launch_screen.dart';
import 'services/api_service.dart';

export 'view/launch_screen.dart';
export 'view/chat_screen.dart';
export 'model/mygpts_model.dart';
export 'services/api_service.dart';

class ChatBot {
  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    print('chatBotId: $chatBotId');
    print('appSecret: $appSecret');
    print('licenseKey: $licenseKey');
    print('isProduction: $isProduction');
    print('userId: $userId');
    print('location: $location');
    print('longitude: $longitude');
    print('latitude: $latitude');
    ApiService.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );
  }

  static void openChatBot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LaunchScreen(),
      ),
    );
  }
}
