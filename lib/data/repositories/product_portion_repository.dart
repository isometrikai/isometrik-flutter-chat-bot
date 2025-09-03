import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/product_portion_response.dart';
import 'package:chat_bot/utils/api_result.dart';

class ProductPortionRepository {
  final ApiClient _apiClient;

  ProductPortionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResult> getProductPortions({
    required String centralProductId,
    required String childProductId,
    required String storeId,
  }) async {
    try {
      final endpoint = '/python/product/portion';
      final queryParams = {
        'centralProductId': centralProductId,
        'childProductId': childProductId,
        'storeId': storeId,
      };

      final result = await _apiClient.get(endpoint, queryParameters: queryParams);
      
      if (result.isSuccess) {
        final response = ProductPortionResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } else {
        return ApiResult.error(result.message ?? 'Failed to load product portions');
      }
    } catch (e) {
      return ApiResult.error('Error loading product portions: $e');
    }
  }
}
