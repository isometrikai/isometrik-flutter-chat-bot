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
    String? location,
    double? longitude,
    double? latitude,
  }) {
    ApiService.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
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
