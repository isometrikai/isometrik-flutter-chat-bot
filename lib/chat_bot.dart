library chat_bot;

import 'package:chat_bot/utils/user_preferences.dart';
import 'package:chat_bot/view/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'view/launch_screen.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'utils/utility.dart';

export 'view/launch_screen.dart';
export 'view/chat_screen.dart';
export 'data/model/mygpts_model.dart';
export 'services/api_service.dart';

class ChatBot {
  static String userId1 = '';
  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    required String location,
    required double longitude,
    required double latitude,
  }) {
    print('chatBotId: $chatBotId');
    print('appSecret: $appSecret');
    print('licenseKey: $licenseKey');
    print('isProduction: $isProduction');
    print('userId: $userId');
    print('name: $name');
    print('timestamp: $timestamp');
    print('userToken: $userToken');
    print('location: $location');
    print('longitude: $longitude');
    print('latitude: $latitude');
    userId1 = userId;
    ApiService.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );
  }

  static void openChatBot(BuildContext context) async {
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
      print('============================userId: $userId1');

    String? savedUserId = await UserPreferences.getUserId();
    print('============================savedUserId: $savedUserId');
    if (savedUserId == null || savedUserId.isEmpty || savedUserId != userId1) {
      UserPreferences.saveUserId(userId1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TutorialScreen(),
        ),
      );
    }else{
      Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const LaunchScreen(),
        ),
      );
    }
  }

  static void isCartUpdate(dynamic cartData) {
    print('isCartUpdate: $cartData');
    // Trigger the cart update callback to notify both ChatScreen and RestaurantScreen
    OrderService().triggerCartUpdate(true);
  }
}
