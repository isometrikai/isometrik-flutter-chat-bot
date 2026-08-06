import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/utility.dart';

/// Reports App Store / Play purchases to the eazylife backend.
///
/// POST `/v1/customer/eazysubscription/purchase`
class SubscriptionPurchaseRepository {
  SubscriptionPurchaseRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.appClient;

  final ApiClient _client;

  static const String _purchaseEndpoint =
      '/v1/customer/eazysubscription/purchase';

  /// Backend plan id (static for now).
  static const String defaultPlanId = 'premium';

  /// Notify backend of a successful store purchase.
  ///
  /// [transactionId] — Apple / Google transaction id  
  /// [receiptData] — App Store receipt / JWS (base64 or JWS string from StoreKit)
  /// [productId] — Store product id (e.g. plan_autorenew_monthly)
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

    print(
      'IAP-API | POST $_purchaseEndpoint | '
      'planId=$planId | productId=$productId | '
      'transactionId=$transactionId | '
      'receiptDataLen=${receiptData.length}',
    );

    final result = await _client.post(_purchaseEndpoint, body);

    if (result.isSuccess) {
      print('IAP-API | SUCCESS | data=${result.data}');
      _applyAccessTokenFromResponse(result.data);
    } else {
      print(
        'IAP-API | ERROR | message=${result.message} | data=${result.data}',
      );
    }

    return result;
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