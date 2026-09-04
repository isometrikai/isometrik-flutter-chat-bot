import 'dart:io';

import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/subscription_history_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/services/in_app_purchase/iap_log_collector.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/utility.dart';

/// Subscription purchase + history APIs (eazylife `appClient` base URL).
///
/// - POST `/v1/customer/eazysubscription/purchase` (Apple)
/// - POST `/v1/customer/eazysubscription/android/purchase` (Google Play)
/// - GET  `/v1/customer/eazysubscription/apple/history` (Apple)
/// - GET  `/v1/customer/eazysubscription/google/history` (Google Play)
class SubscriptionPurchaseRepository {
  SubscriptionPurchaseRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.appClient;

  final ApiClient _client;

  static const String _purchaseEndpoint =
      '/v1/customer/eazysubscription/purchase';
  static const String _appleHistoryEndpoint =
      '/v1/customer/eazysubscription/apple/history';
  static const String _googleHistoryEndpoint =
      '/v1/customer/eazysubscription/google/history';
  static const String _androidPurchaseEndpoint =
      '/v1/customer/eazysubscription/android/purchase';

  static String get _historyEndpoint =>
      Platform.isAndroid ? _googleHistoryEndpoint : _appleHistoryEndpoint;

  static const int defaultHistoryLimit = 20;

  /// Backend plan id (static for now).
  static const String defaultPlanId = 'premium';

  void _apiLog(String message) {
    print(message);
    IapLogCollector.instance.log(message);
  }

  /// Notify backend of a successful App Store purchase.
  Future<ApiResult> reportPurchase({
    required String transactionId,
    required String receiptData,
    required String productId,
    String planId = defaultPlanId,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'productId': productId,
      'transactionId': transactionId,
      'receiptData': receiptData,
    };

    _apiLog(
      'IAP-API | POST $_purchaseEndpoint | '
      'planId=$planId | productId=$productId | '
      'transactionId=$transactionId | '
      'receiptDataLen=${receiptData.length}',
    );

    final result = await _client.post(_purchaseEndpoint, body);

    if (result.isSuccess) {
      _apiLog('IAP-API | SUCCESS | data=${result.data}');
      // _applyAccessTokenFromResponse(result.data);
    } else {
      _apiLog(
        'IAP-API | ERROR | message=${result.message} | data=${result.data}',
      );
    }

    return result;
  }

  /// Notify backend of a successful Google Play purchase.
  ///
  /// [purchaseToken] — Play purchase token
  /// [productId] — Play subscription product id (e.g. zain_pro)
  /// [orderId] — optional Play order id
  Future<ApiResult> reportAndroidPurchase({
    required String purchaseToken,
    required String productId,
    String orderId = '',
    String planId = defaultPlanId,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'purchaseToken': purchaseToken,
      'productId': productId,
      'orderId': orderId,
    };

    _apiLog(
      'IAP-API | POST $_androidPurchaseEndpoint | '
      'planId=$planId | productId=$productId | '
      'orderId=${orderId.isEmpty ? "(empty)" : orderId} | '
      'purchaseTokenLen=${purchaseToken.length}',
    );

    final result = await _client.post(_androidPurchaseEndpoint, body);

    if (result.isSuccess) {
      _apiLog('IAP-API | ANDROID SUCCESS | data=${result.data}');
      // _applyAccessTokenFromResponse(result.data);
    } else {
      _apiLog(
        'IAP-API | ANDROID ERROR | message=${result.message} | '
        'data=${result.data}',
      );
    }

    return result;
  }

  /// GET store subscription history with pagination.
  ///
  /// Uses the Apple endpoint on iOS and the Google endpoint on Android.
  Future<ApiResult> fetchPurchaseHistory({
    int limit = defaultHistoryLimit,
    int skip = 0,
  }) async {
    _apiLog('IAP-API | GET $_historyEndpoint | limit=$limit | skip=$skip');

    final result = await _client.get(
      _historyEndpoint,
      queryParameters: {
        'limit': '$limit',
        'skip': '$skip',
      },
    );

    if (!result.isSuccess) {
      _apiLog('IAP-API | HISTORY ERROR | message=${result.message}');
      return ApiResult.error(
        result.message ?? 'Failed to load subscription history',
        result.data,
        result.statusCode,
      );
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid subscription history response');
    }

    try {
      final parsed = SubscriptionHistoryResponse.fromJson(data);
      _apiLog(
        'IAP-API | HISTORY SUCCESS | '
        'total=${parsed.total} | pageItems=${parsed.items.length} | skip=$skip',
      );
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }

  /// Reads `data.token.accessToken` / `refreshToken` and updates Utility when present.
  void _applyAccessTokenFromResponse(dynamic responseBody) {
    if (responseBody is! Map<String, dynamic>) {
      print('IAP-API | accessToken skip — response is not a map');
      return;
    }

    final data = responseBody['data'];
    if (data is! Map<String, dynamic>) {
      print('IAP-API | accessToken skip — data missing');
      return;
    }

    final token = data['token'];
    if (token is! Map<String, dynamic>) {
      print('IAP-API | accessToken skip — token missing');
      return;
    }

    final accessToken = token['accessToken'];
    if (accessToken is String && accessToken.trim().isNotEmpty) {
      Utility.setUserToken(accessToken.trim());
      print('IAP-API | accessToken set via Utility.setUserToken');
    } else {
      print('IAP-API | accessToken skip — empty or missing');
    }

    final refreshToken = token['refreshToken'];
    if (refreshToken is String && refreshToken.trim().isNotEmpty) {
      Utility.setRefreshToken(refreshToken.trim());
      print('IAP-API | refreshToken set via Utility.setRefreshToken');
    } else {
      print('IAP-API | refreshToken skip — empty or missing');
    }

    OrderService().triggerClickManageScreenOpen({
      'action': 'tokenRefresh',
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    });
  }
}
