import 'dart:async';
import 'dart:convert';

import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';

import '../model/greeting_response.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  // Config
  String _chatBotId = '';
  bool _isProduction = false;
  String? _userId;
  String? _name;
  String? _timestamp;
  String? _userToken;
  String? _location;
  double? _longitude;
  double? _latitude;

  // Endpoints
  // static const String _chatEndpoint = '/v2/chatbot';

  // Use universal API client
  late final ApiClient _serviceClient = UniversalApiClient.instance.serviceClient;
  late final ApiClient _chatClient = UniversalApiClient.instance.chatClient;
  late final ApiClient _appClient = UniversalApiClient.instance.appClient;

  // Public configuration
  void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    String? location,
    double? longitude,
    double? latitude,
    bool? needToShowTutorial
  }) {
    _chatBotId = chatBotId;
    _isProduction = isProduction;
    _userId = userId;
    _name = name;
    _timestamp = timestamp;
    _userToken = userToken;
    _location = location;
    _longitude = longitude;
    _latitude = latitude;
    
    // Configure token manager
    TokenManager.instance.configure(
      appSecret: appSecret,
      licenseKey: licenseKey,
      userToken: userToken
    );
    
    AppLog.info('Environment: ' + (_isProduction ? 'production' : 'staging'));
  }

  Future<void> initialize() async {
    await TokenManager.instance.initialize();
  }

  // Chatbot API
  // Future<MyGPTsResponse?> getChatbotData() async {
  //   final res = await _serviceClient.get(
  //     '/v1/guest/mygpts',
  //     queryParameters: {'id': _chatBotId},
  //   );
  //   if (res.isSuccess && res.data != null) {
  //     try {
  //       final parsed = MyGPTsResponse.fromJson(res.data as Map<String, dynamic>);
  //       return parsed;
  //     } catch (e) {
  //       AppLog.info('Parsing error (getChatbotData): $e');
  //       return null;
  //     }
  //   }
  //   return null;
  // }

  Future<MyGPTsResponse?> getChatbotData() async {
    // Temporary: Direct data loading (remove this when API is ready)
    try {
      final mockResponseData = {
        "message": "Data Found Successfully",
        "data": [
          {
            "id": 1476,
            "bot_identifier": "Q&A Chat bot",
            "account_id": "66c46aea7a6029b9913b3218",
            "project_id": "6f887002-2c47-48ca-a405-0f965ee40261",
            "name": "Eazy Assistant",
            "user_id": "66c46aea7a6029b9913b3218_api-client",
            "ui_preferences": {
              "mode_theme": 1,
              "primary_color": "#3F51B5",
              "bot_bubble_color": "#FFFFFF",
              "user_bubble_color": "#F0DAFE",
              "font_size": "12px",
              "font_style": "Arial",
              "bot_bubble_font_color": "#000000",
              "user_bubble_font_color": "#242424",
              "launcher_image": "",
              "launcher_welcome_message": "Hi! I'm your personal assistant. How can I help you today?",
              "selected_launcher_image_type": 1
            },
            "timezone": "64e5c1f0017128d0df5840cb",
            "template_id": null,
            "suggested_replies": [],
            "profile_image": "https://admin-media1.isometrik.io/ai_bot/_R92GTTRG5.jpg",
            "status": [
              {
                "id": "66c46aea7a6029b9913b3218_api-client",
                "timestamp": 1750744489,
                "statusText": "ACTIVE"
              }
            ],
            "created_at": "2025-06-24 05:54:49",
            "bot_type": "CUSTOMIZED_BOT",
            "welcome_message": [
              "Hi! I'm your personal assistant. How can I help you today?"
            ],
            "app_type": 1
          }
        ],
        "count": 1
      };

      // Simulate network delay (optional)
      await Future.delayed(Duration(milliseconds: 300));

      final parsed = MyGPTsResponse.fromJson(mockResponseData);
      return parsed;
    } catch (e) {
      AppLog.info('Parsing error (getChatbotData - temp): $e');
      return null;
    }
  }

  Future<GreetingResponse?> getInitialOptionData() async {
    final res = await _chatClient.get(
      '/v2/home-screen',
       queryParameters: { 'username': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': _location ?? '',
          'latitude': _latitude.toString(),
          'longitude': _longitude.toString(),
          'user_id': _userId ?? '',
          'username': _name ?? '',
          },
    );
    if (res.isSuccess && res.data != null) {
      try {
        final parsed = GreetingResponse.fromJson(res.data as Map<String, dynamic>);
        return parsed;
      } catch (e) {
        AppLog.info('Parsing error (getChatbotData): $e');
        return null;
      }
    }
    return null;
  }


}
