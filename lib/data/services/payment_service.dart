import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  late final ApiClient _client = UniversalApiClient.instance.appClient;

  /// Add customer payment method to the system
  Future<ApiResult> addCustomerPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      final body = {
        'userId': userId,
        'paymentMethod': paymentMethodId,
      };

      final result = await _client.post('/stripe/v1/customer', body);
      
      if (result.isSuccess) {
        return ApiResult.success(result.data);
      } else {
        return ApiResult.error(result.message ?? 'Unknown error', result.data);
      }
    } catch (e) {
      return ApiResult.error('Failed to add payment method: $e');
    }
  }

  /// Get customer payment methods
  Future<ApiResult> getCustomerPaymentMethods({
    required String userId,
  }) async {
    try {
      final result = await _client.get('/stripe/v1/customer/$userId/payment-methods');
      
      if (result.isSuccess) {
        return ApiResult.success(result.data);
      } else {
        return ApiResult.error(result.message ?? 'Unknown error', result.data);
      }
    } catch (e) {
      return ApiResult.error('Failed to get payment methods: $e');
    }
  }

  /// Delete customer payment method
  Future<ApiResult> deleteCustomerPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      final result = await _client.delete('/stripe/v1/customer/$userId/payment-methods/$paymentMethodId');
      
      if (result.isSuccess) {
        return ApiResult.success(result.data);
      } else {
        return ApiResult.error(result.message ?? 'Unknown error', result.data);
      }
    } catch (e) {
      return ApiResult.error('Failed to delete payment method: $e');
    }
  }
}
