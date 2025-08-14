import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/log.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.buildHeaders,
    this.onUnauthorizedRefresh,
    this.timeout = const Duration(seconds: 120),
  });

  final String baseUrl;
  final Future<Map<String, String>> Function() buildHeaders;
  final Future<bool> Function()? onUnauthorizedRefresh;
  final Duration timeout;

  static const _maxRetryCount = 1; // refresh once on 401

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
    if (result.isUnauthorized && retryCount < _maxRetryCount) {
      final canRefresh = await onUnauthorizedRefresh?.call() ?? false;
      if (canRefresh) {
        return _requestWithRetry(requestFn, retryCount: retryCount + 1);
      }
    }
    return result;
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

      final bool isUnauthorizedByMessage = messageField.contains('Token Not found') ||
          messageField.contains('Unauthorized');

      if (statusCode >= 200 && statusCode < 300) {
        return ApiResult.success(body);
      } else if (statusCode == 401 || isUnauthorizedByMessage) {
        return ApiResult.error('Unauthorized', body);
      } else if (statusCode == 404) {
        return ApiResult.error('Not Found', body);
      } else {
        return ApiResult.error('Error: $statusCode', body);
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
    AppLog.info('API Request -> $method $url');
    AppLog.info('Headers: ${jsonEncode(headers)}');
    if (body == null) return;
    AppLog.info('Body: ${jsonEncode(body)}');
  }

  void _logResponse(
    String method,
    String url,
    int statusCode,
    String responseBody,
  ) {
    AppLog.info('API Response <- $method $url');
    AppLog.info('Status Code: $statusCode');
    AppLog.info('Response: $responseBody');
  }
}
