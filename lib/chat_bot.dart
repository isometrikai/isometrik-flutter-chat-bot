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
  static bool isTutorialShown = false;

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
    required bool needToShowTutorial,
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
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
    print('needToShowTutorial: $needToShowTutorial');
    print('clientGuid: $clientGuid');
    print('indexName: $indexName');
    print('visitId: $visitId');
    print('visitorId: $visitorId');
    print('searchApiUrl: $searchApiUrl');
    isTutorialShown = needToShowTutorial;
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
        needToShowTutorial:needToShowTutorial,
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: searchApiUrl,
    );
  }

  static void openChatBot(BuildContext context) async {
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
    if (isTutorialShown == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LaunchScreen()),
      );
    }
  }

  static void isCartUpdate(dynamic cartData) {
    print('isCartUpdate: $cartData');
    OrderService().triggerCartUpdate(true);
  }
}
