import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/mygpts_model.dart';
import '../model/chat_response.dart';

class ApiService {
  // static String _chatBotId = '2';
  // static String _appSecret = "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M";
  // static String _licenseKey = "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9";

  static String _chatBotId = '';
  static String _appSecret = "";
  static String _licenseKey = "";

  // Optional location variables
  static String? _location;
  static double? _longitude;
  static double? _latitude;

  static const String _baseUrl = 'https://service-apis.isometrik.io';
  static const String _authEndpoint = '/v2/guestAuth';
  static const String _chatEndpoint = '/v1/eazy/agent-chat';
  static const String _tokenKey = 'access_token';

  static String? _accessToken;

  /// Configure API service with required and optional parameters
  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    _chatBotId = chatBotId;
    _appSecret = appSecret;
    _licenseKey = licenseKey;
    _location = location;
    _longitude = longitude;
    _latitude = latitude;
  }

  /// Get current chatbot endpoint with dynamic ID
  static String get _chatbotEndpoint => '/v1/guest/mygpts?id=$_chatBotId';

  /// Get auth body with current configuration
  static Map<String, dynamic> get _authBody => {
    "appSecret": _appSecret,
    "createIsometrikUser": true,
    "fingerprintId": "NjM2MTAzMDYzNjI4NGUwMDEzNzYyMjA5",
    "licensekey": _licenseKey,
  };
  static Future<void> initialize() async {
    await _loadTokenFromStorage();
  }

  /// Load token from SharedPreferences
  static Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      print('📱 Loaded token from storage: ${_accessToken != null ? 'Found' : 'Not found'}');
    } catch (e) {
      print('❌ Error loading token from storage: $e');
      _accessToken = null;
    }
  }

  /// Save token to SharedPreferences
  static Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('💾 Token saved to storage successfully');
    } catch (e) {
      print('❌ Error saving token to storage: $e');
    }
  }

  /// Clear token from SharedPreferences
  static Future<void> _clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('🗑️ Token cleared from storage');
    } catch (e) {
      print('❌ Error clearing token from storage: $e');
    }
  }

  /// Fetches chatbot data, handling token refresh if needed
  static Future<MyGPTsResponse?> getChatbotData() async {
    try {
      // Ensure token is loaded
      if (_accessToken == null) {
        await _loadTokenFromStorage();
      }

      // First attempt with current token
      final response = await _fetchChatbotData();

      if (response != null) {
        return response;
      }

      // If failed, refresh token and try again
      final newToken = await _refreshToken();
      if (newToken != null) {
        _accessToken = newToken;
        await _saveTokenToStorage(newToken);
        return await _fetchChatbotData();
      }

      return null;
    } catch (e) {
      print('Error in getChatbotData: $e');
      return null;
    }
  }

  /// Fetches chatbot data with current token
  static Future<MyGPTsResponse?> _fetchChatbotData() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      print('❌ No access token available');
      return null;
    }

    try {
      final url = '$_baseUrl$_chatbotEndpoint';

      print('=== CHATBOT API DEBUG ===');
      print('URL: $url');
      print('Method: GET');
      print('Authorization: ${_accessToken!.substring(0, 20)}...');
      print('Headers: Authorization: $_accessToken, Content-Type: application/json');
      print('========================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': _accessToken!,
          'Content-Type': 'application/json',
        },
      );

      print('=== CHATBOT API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('===========================');

      if (response.statusCode == 200) {
        print('✅ Chatbot data fetch successful');
        final chatbotResponse = MyGPTsResponse.fromJson(json.decode(response.body));
        print(chatbotResponse.data.first.uiPreferences.primaryColor);
        return chatbotResponse;
      } else if (response.statusCode == 401) {
        // Token expired or invalid, remove from storage
        await _clearTokenFromStorage();
        _accessToken = null;
        
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] == 'Token Not found.') {
            print('🔄 Token expired, will refresh');
            return null; // Signal to refresh token
          }
        } catch (e) {
          print('❌ Error parsing 401 response: $e');
        }
      }

      print('❌ Chatbot API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Network error in _fetchChatbotData: $e');
      return null;
    }
  }

  /// Send chat message to the agent
  static Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) async {
    try {
      // Ensure token is loaded
      if (_accessToken == null) {
        await _loadTokenFromStorage();
      }

      // First attempt with current token
      final response = await _sendChatMessageRequest(
        message: message,
        agentId: agentId,
        fingerPrintId: fingerPrintId,
        sessionId: sessionId,
        isLoggedIn: isLoggedIn,
        longitude: longitude,
        latitude: latitude,
      );

      if (response != null) {
        return response;
      }

      // If failed, refresh token and try again
      final newToken = await _refreshToken();
      if (newToken != null) {
        _accessToken = newToken;
        await _saveTokenToStorage(newToken);
        return await _sendChatMessageRequest(
          message: message,
          agentId: agentId,
          fingerPrintId: fingerPrintId,
          sessionId: sessionId,
          isLoggedIn: isLoggedIn,
          longitude: longitude,
          latitude: latitude,
        );
      }

      return null;
    } catch (e) {
      print('Error in sendChatMessage: $e');
      return null;
    }
  }

  /// Send chat message request with current token
  static Future<ChatResponse?> _sendChatMessageRequest({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      print('❌ No access token available for chat');
      return null;
    }

    try {
      final url = '$_baseUrl$_chatEndpoint';

      final requestBody = {
        "isLoggedIn": isLoggedIn,
        "agent_id": agentId,
        "finger_print_id": fingerPrintId,
        "message": message,
        "longitude": longitude.toString(),
        "latitude": latitude.toString(),
        "session_id": sessionId,
      };

      final requestBodyJson = json.encode(requestBody);

      print('=== CHAT API DEBUG ===');
      print('URL: $url');
      print('Method: POST');
      print('Authorization: Bearer ${_accessToken!.substring(0, 20)}...');
      print(
          'Headers: Authorization: Bearer $_accessToken, Content-Type: application/json');
      print('Body: $requestBodyJson');
      print('======================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'Content-Length': requestBodyJson.length.toString(),
        },
        body: requestBodyJson,
      );

      print('=== CHAT API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        print('✅ Chat message sent successfully');
        final chatResponse = ChatResponse.fromJson(json.decode(response.body));
        return chatResponse;
      } else if (response.statusCode == 401) {
        // Token expired or invalid, remove from storage
        await _clearTokenFromStorage();
        _accessToken = null;

        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] == 'Token Not found.' ||
              errorBody['message']?.toString().contains('Unauthorized') ==
                  true) {
            print('🔄 Token expired for chat, will refresh');
            return null; // Signal to refresh token
          }
        } catch (e) {
          print('❌ Error parsing 401 response for chat: $e');
        }
      }

      print('❌ Chat API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Network error in _sendChatMessageRequest: $e');
      return null;
    }
  }

  /// Refreshes the access token
  static Future<String?> _refreshToken() async {
    try {
      final requestBody = json.encode(_authBody);
      final url = '$_baseUrl$_authEndpoint';

      print('=== AUTH API DEBUG ===');
      print('URL: $url');
      print('Method: POST');
      print('Headers: Content-Type: application/json');
      print('Body: $requestBody');
      print('Body length: ${requestBody.length}');
      print('=====================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('=== AUTH API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Body Length: ${response.body.length}');
      print('========================');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Success') {
          final newToken = responseData['data']['accessToken'];
          print('✅ Token refresh successful');
          
          // Save new token to storage
          await _saveTokenToStorage(newToken);
          
          return newToken;
        } else {
          print('❌ Unexpected response message: ${responseData['message']}');
        }
      }

      print('❌ Auth API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Network error in _refreshToken: $e');
      return null;
    }
  }

  /// Manually refresh token (for testing or manual refresh)
  static Future<bool> refreshToken() async {
    final newToken = await _refreshToken();
    if (newToken != null) {
      _accessToken = newToken;
      await _saveTokenToStorage(newToken);
      return true;
    }
    return false;
  }

  /// Clear all stored data (logout)
  static Future<void> clearStoredData() async {
    _accessToken = null;
    await _clearTokenFromStorage();
  }

  /// Get current token status
  static String? get currentToken => _accessToken;
}
