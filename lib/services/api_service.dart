import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/mygpts_model.dart';
import '../model/chat_response.dart';
import '../utils/log.dart';

class ApiService {
  static String _chatBotId = '';
  static String _appSecret = "";
  static String _licenseKey = "";
  static bool isProduction = false;

  // Optional location variables
  static String? updateLocation;
  static double? updateLongitude;
  static double? updateLatitude;
  static String? updateName;
  static String? updateTimestamp;
  static String? userID;

  static const String _baseUrl = 'https://service-apis.isometrik.io';
  static const String _chatBaseUrl = 'https://easyagentapi.isometrik.ai';
  static const String _authEndpoint = '/v2/guestAuth';
  static const String _chatEndpoint = '/v1/chatbot';
  static const String _tokenKey = 'access_token';

  static String? _accessToken;

  static const Duration _requestTimeout = Duration(seconds: 120);
  static const String _timeoutErrorMessage = "Something went wrong please try again later";

  /// Configure API service with required and optional parameters
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
    _chatBotId = chatBotId;
    _appSecret = appSecret;
    _licenseKey = licenseKey;
    isProduction = isProduction;
    userID = userId;
    updateName = name;
    updateTimestamp = timestamp;
    updateLocation = location;
    updateLongitude = longitude;
    updateLatitude = latitude;
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
      AppLog.info('📱 Loaded token from storage: ${_accessToken != null ? 'Found' : 'Not found'}');
    } catch (e) {
      AppLog.info('❌ Error loading token from storage: $e');
      _accessToken = null;
    }
  }

  /// Save token to SharedPreferences
  static Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      AppLog.info('💾 Token saved to storage successfully');
    } catch (e) {
      AppLog.info('❌ Error saving token to storage: $e');
    }
  }

  /// Clear token from SharedPreferences
  static Future<void> _clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      AppLog.info('🗑️ Token cleared from storage');
    } catch (e) {
      AppLog.info('❌ Error clearing token from storage: $e');
    }
  }

  /// Generate cURL command for GET requests
  static String _generateGetCurlCommand(String url, Map<String, String> headers) {
    final headerParams = headers.entries
        .map((entry) => '-H "${entry.key}: ${_escapeHeaderValue(entry.value)}"')
        .join(' \\\n  ');

    return '''curl -X GET "$url" \\
  $headerParams''';
  }

  /// Generate cURL command for POST requests
  static String _generatePostCurlCommand(String url, String requestBody, Map<String, String> headers) {
    final headerParams = headers.entries
        .map((entry) => '-H "${entry.key}: ${_escapeHeaderValue(entry.value)}"')
        .join(' \\\n  ');

    // Escape the request body for shell
    final escapedBody = requestBody
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return '''curl -X POST "$url" \\
  $headerParams \\
  -d "$escapedBody"''';
  }

  /// Escape header values for shell safety
  static String _escapeHeaderValue(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"');
  }

  /// Log API request details with cURL command
  static void _logApiRequest({
    required String apiName,
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
  }) {
    AppLog.info('URL: $url');
    if (body != null) {
      AppLog.info('Body: $body');
    }

    // Generate and log cURL command
    final curlCommand = method.toUpperCase() == 'GET'
        ? _generateGetCurlCommand(url, headers)
        : _generatePostCurlCommand(url, body ?? '', headers);

    AppLog.info('\n=== $apiName cURL COMMAND ===');
    AppLog.info(curlCommand);
    AppLog.info('================================\n');
  }

  /// Log API response details
  static void _logApiResponse({
    required String apiName,
    required http.Response response,
  }) {
    AppLog.info('=== $apiName API RESPONSE ===');
    AppLog.info('Response Body: ${response.body}');
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
      AppLog.info('Error in getChatbotData: $e');
      return null;
    }
  }

  /// Fetches chatbot data with current token
  static Future<MyGPTsResponse?> _fetchChatbotData() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      AppLog.info('❌ No access token available');
      return null;
    }

    try {
      final url = '$_baseUrl$_chatbotEndpoint';
      final headers = {
        'Authorization': _accessToken!,
        'Content-Type': 'application/json',
      };

      // Log request with cURL
      _logApiRequest(
        apiName: 'CHATBOT',
        method: 'GET',
        url: url,
        headers: headers,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(_requestTimeout);

      // Log response
      _logApiResponse(apiName: 'CHATBOT', response: response);

      if (response.statusCode == 200) {
        AppLog.info('✅ Chatbot data fetch successful');
        final chatbotResponse = MyGPTsResponse.fromJson(json.decode(response.body));
        AppLog.info(chatbotResponse.data.first.uiPreferences.primaryColor);
        return chatbotResponse;
      } else if (response.statusCode == 401) {
        // Token expired or invalid, remove from storage
        await _clearTokenFromStorage();
        _accessToken = null;

        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] == 'Token Not found.') {
            AppLog.info('🔄 Token expired, will refresh');
            return null; // Signal to refresh token
          }
        } catch (e) {
          AppLog.info('❌ Error parsing 401 response: $e');
        }
      }

      AppLog.info('❌ Chatbot API error: ${response.statusCode} - ${response.body}');
      return null;
    } on TimeoutException catch (e) {
      AppLog.info('❌ Request timeout: $e');
      throw Exception(_timeoutErrorMessage);
    } catch (e) {
      AppLog.info('❌ Network error in _fetchChatbotData: $e');
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
        longitude: updateLongitude ?? 0.0,
        latitude: updateLatitude ?? 0.0,
        name: updateName ?? '',
        timestamp: updateTimestamp ?? '',
        location: updateLocation ?? ''
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
          longitude: updateLongitude ?? 0.0,
          latitude: updateLatitude ?? 0.0,
            name: updateName ?? '',
            timestamp: updateTimestamp ?? '',
            location: updateLocation ?? ''
        );
      }

      return null;
    } catch (e) {
      AppLog.info('Error in sendChatMessage: $e');
      return null;
    }
  }

  /// Send chat message request with current token
  static Future<ChatResponse?> _sendChatMessageRequest({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    required String name,
    required String timestamp,
    required String location,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      AppLog.info('❌ No access token available for chat');
      return null;
    }

    try {
      final url = '$_chatBaseUrl$_chatEndpoint';

      final requestBody = {
        "user_id": userID,
        "device_id": fingerPrintId,
        "query": message,
        "session_id": sessionId,
        "location": {
          "latitude": latitude.toString(),
          "longitude": longitude.toString()
        },
        "user_data": {
          "name": name,
          "timestamp": timestamp,
          "location": location
        }
      };

      final requestBodyJson = json.encode(requestBody);
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
        'Content-Length': requestBodyJson.length.toString(),
      };

      // Log request with cURL
      _logApiRequest(
        apiName: 'CHAT',
        method: 'POST',
        url: url,
        headers: headers,
        body: requestBodyJson,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBodyJson,
      ).timeout(_requestTimeout);

      // Log response
      _logApiResponse(apiName: 'CHAT', response: response);

      if (response.statusCode == 200) {
        AppLog.info('✅ Chat message sent successfully');
        final chatResponse = ChatResponse.fromJson(json.decode(response.body));
        return chatResponse;
      } else if (response.statusCode == 401) {
        // Token expired or invalid, remove from storage
        await _clearTokenFromStorage();
        _accessToken = null;

        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] == 'Token Not found.' ||
              errorBody['message']?.toString().contains('Unauthorized') == true) {
            AppLog.info('🔄 Token expired for chat, will refresh');
            return null; // Signal to refresh token
          }
        } catch (e) {
          AppLog.info('❌ Error parsing 401 response for chat: $e');
        }
      }

      AppLog.info('❌ Chat API error: ${response.statusCode} - ${response.body}');
      return null;
    } on TimeoutException catch (e) {
      AppLog.info('❌ Chat request timeout: $e');
      throw Exception(_timeoutErrorMessage);
    } catch (e) {
      AppLog.info('❌ Network error in _sendChatMessageRequest: $e');
      return null;
    }
  }

  /// Refreshes the access token
  static Future<String?> _refreshToken() async {
    try {
      final requestBody = json.encode(_authBody);
      final url = '$_baseUrl$_authEndpoint';
      final headers = {
        'Content-Type': 'application/json',
      };

      // Log request with cURL
      _logApiRequest(
        apiName: 'AUTH',
        method: 'POST',
        url: url,
        headers: headers,
        body: requestBody,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      ).timeout(_requestTimeout);

      // Log response
      _logApiResponse(apiName: 'AUTH', response: response);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Success') {
          final newToken = responseData['data']['accessToken'];
          AppLog.info('✅ Token refresh successful');

          // Save new token to storage
          await _saveTokenToStorage(newToken);

          return newToken;
        } else {
          AppLog.info('❌ Unexpected response message: ${responseData['message']}');
        }
      }

      AppLog.info('❌ Auth API error: ${response.statusCode} - ${response.body}');
      return null;
    } on TimeoutException catch (e) {
      AppLog.info('❌ Auth request timeout: $e');
      throw Exception(_timeoutErrorMessage);
    } catch (e) {
      AppLog.info('❌ Network error in _refreshToken: $e');
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