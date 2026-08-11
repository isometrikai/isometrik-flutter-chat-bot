import 'dart:async';
import 'dart:convert';

import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:http/http.dart' as http;

/// Refreshes eazylife user access tokens via `POST /v1/generateToken`.
/// Used when app APIs return 406 (or other unauthorized responses).
/// Not used by HawkSearch or Isometrik service APIs.
class UserTokenRefreshManager {
  UserTokenRefreshManager._internal();
  static final UserTokenRefreshManager instance =
      UserTokenRefreshManager._internal();

  static const String _endpoint = '/v1/generateToken';

  String _baseApiUrl = '';
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];

  /// Keep base URL in sync with [ApiService.configure].
  void configure({required String baseApiUrl}) {
    _baseApiUrl = baseApiUrl;
  }

  /// Exchange [Utility.refreshToken] + current access token for a new access token.
  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    print('🔄 Refreshing eazylife user token via generateToken...');

    try {
      final refToken = Utility.getRefreshToken().trim();
      final accessToken = _stripBearer(Utility.getUserToken()).trim();
      final baseUrl = _baseApiUrl.trim();

      if (baseUrl.isEmpty) {
        print('❌ User token refresh skipped: baseApiUrl not configured');
        _completeRefreshRequests(false);
        return false;
      }

      if (refToken.isEmpty || accessToken.isEmpty) {
        print(
          '❌ User token refresh skipped: missing refToken or accessToken',
        );
        _completeRefreshRequests(false);
        return false;
      }

      final requestBody = jsonEncode({
        'refToken': refToken,
        'accessToken': accessToken,
      });

      final uri = Uri.parse('$baseUrl$_endpoint');
      final headers = {'Content-Type': 'application/json'};

      AppLog.curl('POST', uri.toString(), headers, requestBody);

      final response = await http
          .post(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 120));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic responseData =
            response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final dynamic data =
            responseData is Map<String, dynamic> ? responseData['data'] : null;
        final dynamic newAccessToken =
            data is Map<String, dynamic> ? data['accessToken'] : null;

        if (newAccessToken is String && newAccessToken.trim().isNotEmpty) {
          final tokenToStore = _formatAccessToken(newAccessToken.trim());
          Utility.setUserToken(tokenToStore);
          print('✅ Eazylife user token refresh successful');

          // Notify host so it can persist the updated access token.
          OrderService().triggerClickManageScreenOpen({
            'action': 'tokenRefresh',
            'accessToken': tokenToStore,
            'refreshToken': Utility.getRefreshToken(),
          });

          _completeRefreshRequests(true);
          return true;
        }
      }

      print(
        '❌ User token refresh failed: ${response.statusCode} ${response.body}',
      );
      _completeRefreshRequests(false);
      return false;
    } catch (e) {
      print('❌ User token refresh error: $e');
      _completeRefreshRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  String _stripBearer(String token) {
    if (token.startsWith('Bearer ')) {
      return token.substring(7);
    }
    return token;
  }

  /// Preserve existing `Bearer ` prefix style used by the host app.
  String _formatAccessToken(String newToken) {
    final current = Utility.getUserToken();
    if (current.startsWith('Bearer ') && !newToken.startsWith('Bearer ')) {
      return 'Bearer $newToken';
    }
    return newToken;
  }

  void _completeRefreshRequests(bool success) {
    for (final completer in _refreshCompleters) {
      completer.complete(success);
    }
    _refreshCompleters.clear();
  }
}
