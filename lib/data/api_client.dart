import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:chat_bot/utils/utility.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.buildHeaders,
    this.onUnauthorizedRefresh,
    this.onTokenExpiredLogout,
    this.timeout = const Duration(seconds: 120),
  });

  final String baseUrl;
  final Future<Map<String, String>> Function() buildHeaders;
  final Future<bool> Function()? onUnauthorizedRefresh;

  /// Called once when an eazylife API returns 401 — host should logout.
  final void Function()? onTokenExpiredLogout;
  final Duration timeout;

  static const _maxRetryCount = 2; // refresh twice on 406
  static bool _logoutTriggered = false;

  /// Reset logout guard (e.g. after a fresh configure / login).
  static void resetLogoutGuard() {
    _logoutTriggered = false;
  }

  Future<ApiResult> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) =>
      _requestWithRetry(() async {
        final uri = Uri.parse('$baseUrl$endpoint').replace(
          queryParameters: queryParameters,
        );
        final headers = await buildHeaders();
        _logRequest('GET', uri.toString(), headers);
        // Print curl for every request
        AppLog.curl('GET', uri.toString(), headers);
        final response = await http.get(uri, headers: headers).timeout(timeout);
        _logResponse('GET', uri.toString(), response.statusCode, response.body);
        return _processResponse(response);
      });

  Future<ApiResult> post(String endpoint, Map<String, dynamic> body) =>
      _requestWithRetry(() async {
        final uri = Uri.parse('$baseUrl$endpoint');
        final headers = await buildHeaders();
        final encodedBody = jsonEncode(body);
        _logRequest('POST', uri.toString(), headers, body);
        AppLog.curl('POST', uri.toString(), headers, encodedBody);
        final response = await http
            .post(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        _logResponse('POST', uri.toString(), response.statusCode, response.body);
        return _processResponse(response);
      });

  Future<ApiResult> patch(String endpoint, Map<String, dynamic> body) =>
      _requestWithRetry(() async {
        final uri = Uri.parse('$baseUrl$endpoint');
        final headers = await buildHeaders();
        final encodedBody = jsonEncode(body);
        _logRequest('PATCH', uri.toString(), headers, body);
        AppLog.curl('PATCH', uri.toString(), headers, encodedBody);
        final response = await http
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        _logResponse(
          'PATCH',
          uri.toString(),
          response.statusCode,
          response.body,
        );
        return _processResponse(response);
      });

  Future<ApiResult> delete(String endpoint) => _requestWithRetry(() async {
        final uri = Uri.parse('$baseUrl$endpoint');
        final headers = await buildHeaders();
        _logRequest('DELETE', uri.toString(), headers);
        AppLog.curl('DELETE', uri.toString(), headers);
        final response = await http.delete(uri, headers: headers).timeout(timeout);
        _logResponse(
          'DELETE',
          uri.toString(),
          response.statusCode,
          response.body,
        );
        return _processResponse(response);
      });

  Future<ApiResult> put(String endpoint, {Map<String, dynamic>? body}) =>
      _requestWithRetry(() async {
        final uri = Uri.parse('$baseUrl$endpoint');
        final headers = await buildHeaders();
        final encodedBody = jsonEncode(body);
        _logRequest('PUT', uri.toString(), headers, body);
        AppLog.curl('PUT', uri.toString(), headers, encodedBody);
        final response = await http
            .put(uri, headers: headers, body: encodedBody)
            .timeout(timeout);
        _logResponse('PUT', uri.toString(), response.statusCode, response.body);
        return _processResponse(response);
      });

  Future<ApiResult> _requestWithRetry(
    Future<ApiResult> Function() requestFn, {
    int retryCount = 0,
  }) async {
    final result = await requestFn();

    // 401 → logout from host app (eazylife clients only).
    if (result.isTokenExpired) {
      if (onTokenExpiredLogout != null) {
        _triggerLogoutOnce();
        return result;
      }
      // Isometrik / clients without logout handler: try existing refresh path.
      if (onUnauthorizedRefresh != null && retryCount < _maxRetryCount) {
        print('🔄 Token expired (401), attempting refresh...');
        final canRefresh = await onUnauthorizedRefresh!.call();
        if (canRefresh) {
          print('🔄 Token refreshed, retrying request...');
          return _requestWithRetry(requestFn, retryCount: retryCount + 1);
        }
      }
      return result;
    }

    // 406 (and other Unauthorized) → refresh + retry.
    if (result.isUnauthorized && retryCount < _maxRetryCount) {
      print('🔄 Token expired, attempting refresh...');
      bool canRefresh = false;
      if (onUnauthorizedRefresh != null) {
        canRefresh = await onUnauthorizedRefresh!.call();
      }
      if (canRefresh) {
        print('🔄 Token refreshed, retrying request...');
        return _requestWithRetry(requestFn, retryCount: retryCount + 1);
      }
    }
    return result;
  }

  void _triggerLogoutOnce() {
    if (_logoutTriggered) return;
    _logoutTriggered = true;
    print('🚪 Token expired (401), triggering token_expired_logout...');
    onTokenExpiredLogout!.call();
  }

  ApiResult _processResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;
      final dynamic body =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      // Detect unauthorized by status or message content
      final String messageField = (() {
        if (body is Map<String, dynamic>) {
          final dynamic m = body['message'];
          if (m is String) return m;
        }
        return '';
      })();

      final dynamic bodyStatus =
          body is Map<String, dynamic> ? body['status'] : null;
      final bool is406ByBody =
          bodyStatus == 406 || bodyStatus == '406';
      final bool is401ByBody =
          bodyStatus == 401 || bodyStatus == '401';

      final bool isUnauthorizedByMessage = messageField.contains('Token Not found') ||
          messageField.contains('Unauthorized') ||
          messageField.contains('Token Expired');

      if (statusCode >= 200 && statusCode < 300 && !is406ByBody && !is401ByBody) {
        return ApiResult.success(body);
      } else if (statusCode == 401 || is401ByBody) {
        return ApiResult.error('TokenExpired', body, 401);
      } else if (statusCode == 400 ||
          statusCode == 406 ||
          is406ByBody ||
          isUnauthorizedByMessage) {
        return ApiResult.error('Unauthorized', body, statusCode);
      } else if (statusCode == 404) {
        return ApiResult.error('Not Found', body, statusCode);
      } else {
        return ApiResult.error('Error: $statusCode', body, statusCode);
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  void _logRequest(
    String method,
    String url,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    print('API Request -> $method $url');
    AppLog.printLong('Headers: ${jsonEncode(headers)}');
    // TODO(TEMP): Remove debug access-token popup after debugging.
    Utility.showDebugAccessTokenAlert(apiLabel: '$method $url');
    if (body == null) return;
    AppLog.printLong('Body: ${jsonEncode(body)}');
  }

  void _logResponse(
    String method,
    String url,
    int statusCode,
    String responseBody,
  ) {
    print('API Response <- $method $url');
    print('Status Code: $statusCode');
    print('Response: $responseBody');
  }
}
