import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';
import 'package:chat_bot/utils/api_result.dart';

class GroceryProductRepository {
  final ApiClient _apiClient;

  GroceryProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResult> getGroceryProductDetails({
    required String parentProductId,
    required String productId,
    required String storeId,
  }) async {
    try {
      final endpoint = '/python/product/details';
      final queryParams = {
        'parentProductId': parentProductId,
        'productId': productId,
        'storeId': storeId,
      };

      final result = await _apiClient.get(endpoint, queryParameters: queryParams);
      
      if (result.isSuccess) {
        final response = GroceryProductDetailsResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } else {
        return ApiResult.error(result.message ?? 'Failed to load grocery product details');
      }
    } catch (e) {
      return ApiResult.error('Error loading grocery product details: $e');
    }
  }
}
