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
  static const String _chatEndpoint = '/v2/test-response';

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
  Future<MyGPTsResponse?> getChatbotData() async {
    final res = await _serviceClient.get(
      '/v1/guest/mygpts',
      queryParameters: {'id': _chatBotId},
    );
    if (res.isSuccess && res.data != null) {
      try {
        final parsed = MyGPTsResponse.fromJson(res.data as Map<String, dynamic>);
        return parsed;
      } catch (e) {
        AppLog.info('Parsing error (getChatbotData): $e');
        return null;
      }
    }
    return null;
  }

  Future<GreetingResponse?> getInitialOptionData() async {
    final res = await _chatClient.get(
      '/v2/home-screen',
      queryParameters: { 'username': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': _location ?? '',},
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

  Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) async {
    final body = {
      'user_id': _userId,
      'device_id': fingerPrintId,
      'query': message,
      'session_id': sessionId,
      'location': {
        'latitude': (latitude == 0.0 ? (_latitude ?? 0.0) : latitude).toString(),
        'longitude': (longitude == 0.0 ? (_longitude ?? 0.0) : longitude).toString(),
      },
      'user_data': {
        'name': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': _location ?? '',
      }
    };
    final res = await _chatClient.post(_chatEndpoint, body);
    if (res.isSuccess && res.data != null) {
      try {
        final parsed = ChatResponse.fromJson(res.data as Map<String, dynamic>);
        return parsed;
      } catch (e) {
        AppLog.info('Parsing error (sendChatMessage): $e');
        return null;
      }
    }
    return null;
  }

  bool get isProduction => _isProduction;
}
