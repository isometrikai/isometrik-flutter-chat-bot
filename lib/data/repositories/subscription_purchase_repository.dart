import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

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
  Future<ApiResult> reportPurchase({
    required String transactionId,
    required String receiptData,
    String planId = defaultPlanId,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'transactionId': transactionId,
      'receiptData': receiptData,
    };

    print(
      'IAP-API | POST $_purchaseEndpoint | '
      'planId=$planId | transactionId=$transactionId | '
      'receiptDataLen=${receiptData.length}',
    );

    final result = await _client.post(_purchaseEndpoint, body);

    if (result.isSuccess) {
      print('IAP-API | SUCCESS | data=${result.data}');
    } else {
      print(
        'IAP-API | ERROR | message=${result.message} | data=${result.data}',
      );
    }

    return result;
  }
}
