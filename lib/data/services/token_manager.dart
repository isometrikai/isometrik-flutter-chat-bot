import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_bot/utils/log.dart';

/// Centralized token manager for handling authentication tokens across all APIs
class TokenManager {
  TokenManager._internal();
  static final TokenManager instance = TokenManager._internal();

  // Configuration
  String _appSecret = '';
  String _licenseKey = '';
  String _baseUrl = 'https://service-apis.isometrik.io';
  String _authEndpoint = '/v2/guestAuth';

  // Token storage
  static const String _tokenKey = 'access_token';
  String? _accessToken;
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];

  /// Configure the token manager with authentication credentials
  void configure({
    required String appSecret,
    required String licenseKey,
    String? baseUrl,
    String? authEndpoint,
  }) {
    _appSecret = appSecret;
    _licenseKey = licenseKey;
    if (baseUrl != null) _baseUrl = baseUrl;
    if (authEndpoint != null) _authEndpoint = authEndpoint;
  }

  /// Initialize token manager and load existing token
  Future<void> initialize() async {
    await _loadTokenFromStorage();
    if ((_accessToken ?? '').isEmpty) {
      await refreshToken();
    }
  }

  /// Get the current authorization header
  String? get authorizationHeader {
    if ((_accessToken ?? '').isEmpty) return null;
    return _accessToken!.startsWith('Bearer ') ? _accessToken! : 'Bearer $_accessToken';
  }

  /// Get the current token value
  String? get currentToken => _accessToken;

  /// Check if token is available
  bool get hasToken => (_accessToken ?? '').isNotEmpty;

  /// Refresh token with automatic deduplication
  Future<bool> refreshToken() async {
    // If already refreshing, wait for the current refresh to complete
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    AppLog.info('🔄 Refreshing authentication token...');

    try {
      final requestBody = jsonEncode({
        'appSecret': _appSecret,
        'createIsometrikUser': true,
        'fingerprintId': 'NjM2MTAzMDYzNjI4NGUwMDEzNzYyMjA5',
        'licensekey': _licenseKey,
      });

      final uri = Uri.parse('$_baseUrl$_authEndpoint');
      final headers = {'Content-Type': 'application/json'};

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
          
          // Complete all waiting refresh requests
          _completeRefreshRequests(true);
          return true;
        }
      }

      AppLog.info('❌ Token refresh failed: ${response.statusCode} ${response.body}');
      _completeRefreshRequests(false);
      return false;

    } catch (e) {
      AppLog.info('❌ Token refresh error: $e');
      _completeRefreshRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clear stored token
  Future<void> clearToken() async {
    _accessToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
  }

  /// Load token from storage
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      AppLog.info('📱 Loaded token from storage: ${_accessToken != null ? 'Found' : 'Not found'}');
    } catch (e) {
      _accessToken = null;
    }
  }

  /// Save token to storage
  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {}
  }

  /// Complete all waiting refresh requests
  void _completeRefreshRequests(bool success) {
    for (final completer in _refreshCompleters) {
      completer.complete(success);
    }
    _refreshCompleters.clear();
  }

  /// Force refresh token (for manual refresh scenarios)
  Future<bool> forceRefreshToken() async {
    _isRefreshing = false;
    _refreshCompleters.clear();
    return refreshToken();
  }
}
