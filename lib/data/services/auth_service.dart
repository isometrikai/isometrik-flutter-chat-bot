import 'dart:async';
import 'dart:convert';

import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/model/chat_response.dart';

import '../model/greeting_response.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  // Config
  String _chatBotId = '';
  String _appSecret = '';
  String _licenseKey = '';
  bool _isProduction = false;
  String? _userId;
  String? _name;
  String? _timestamp;
  String? _location;
  double? _longitude;
  double? _latitude;

  // Storage
  static const String _tokenKey = 'access_token';
  String? _accessToken;

  // Endpoints
  static const String _baseUrl = 'https://service-apis.isometrik.io';
  static const String _chatBaseUrl = 'https://easyagentapi.isometrik.ai';
  static const String _authEndpoint = '/v2/guestAuth';
  // static const String _chatEndpoint = '/v1/chatbot';
  static const String _chatEndpoint = '/v2/test-response';

  late final ApiClient _serviceClient = ApiClient(
    baseUrl: _baseUrl,
    buildHeaders: () async => {
      'Content-Type': 'application/json',
      if ((_accessToken ?? '').isNotEmpty) 'Authorization': _accessToken!,
    },
    onUnauthorizedRefresh: _refreshToken,
  );

  late final ApiClient _chatClient = ApiClient(
    baseUrl: _chatBaseUrl,
    buildHeaders: () async => {
      'Content-Type': 'application/json',
      if ((_accessToken ?? '').isNotEmpty) 'Authorization': 'Bearer $_accessToken',
    },
    onUnauthorizedRefresh: _refreshToken,
  );

  // Public configuration
  void configure({
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
    _chatBotId = chatBotId;
    _appSecret = appSecret;
    _licenseKey = licenseKey;
    _isProduction = isProduction;
    _userId = userId;
    _name = name;
    _timestamp = timestamp;
    _location = location;
    _longitude = longitude;
    _latitude = latitude;
    AppLog.info('Environment: ' + (_isProduction ? 'production' : 'staging'));
  }

  Future<void> initialize() async {
    await _loadTokenFromStorage();
    // Ensure we have a token at app start to avoid 400 Token Not found
    if ((_accessToken ?? '').isEmpty) {
      final ok = await _refreshToken();
      if (!ok) {
        AppLog.info('Initial token fetch failed; proceeding without token');
      }
    }
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

  // Token handling
  Future<bool> _refreshToken() async {
    try {
      final requestBody = jsonEncode({
        'appSecret': _appSecret,
        'createIsometrikUser': true,
        'fingerprintId': 'NjM2MTAzMDYzNjI4NGUwMDEzNzYyMjA5',
        'licensekey': _licenseKey,
      });
      final uri = Uri.parse('$_baseUrl$_authEndpoint');
      final headers = {'Content-Type': 'application/json'};

      // Print curl for token refresh as well
      AppLog.curl('POST', uri.toString(), headers, requestBody);

      final response = await http
          .post(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'Success') {
          final newToken = responseData['data']['accessToken'];
          _accessToken = newToken;
          await _saveTokenToStorage(newToken);
          AppLog.info('✅ Token refresh successful');
          return true;
        }
      }
      AppLog.info('Auth refresh failed: ${response.statusCode} ${response.body}');
      return false;
    } on TimeoutException catch (e) {
      AppLog.info('Auth refresh timeout: $e');
      return false;
    } catch (e) {
      AppLog.info('Auth refresh error: $e');
      return false;
    }
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      AppLog.info('Loaded token from storage: ${_accessToken != null ? 'Found' : 'Not found'}');
    } catch (e) {
      _accessToken = null;
    }
  }

  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {}
  }

  Future<void> clearStoredData() async {
    _accessToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
  }

  // Sample: Keep your example OTP verification demonstrating ApiClient usage
  late final ApiClient _exampleClient = ApiClient(
    baseUrl: _baseUrl,
    buildHeaders: () async => {
      'Content-Type': 'application/json',
      if ((_accessToken ?? '').isNotEmpty) 'Authorization': _accessToken!,
    },
    onUnauthorizedRefresh: _refreshToken,
  );

  Future<ApiResult> verifyChangePhoneOtp({
    required String currentPhoneNumber,
    required String newPhoneNumber,
    required String countryCode,
    required String otp,
  }) {
    return _exampleClient.post(
      '/api/v1/users/change-phone-verify',
      {
        'current_phone_number': currentPhoneNumber,
        'new_phone_number': newPhoneNumber,
        'country_code': countryCode,
        'otp': otp,
      },
    );
  }

  // Expose getters if needed
  String? get currentToken => _accessToken;
  bool get isProduction => _isProduction;
}
