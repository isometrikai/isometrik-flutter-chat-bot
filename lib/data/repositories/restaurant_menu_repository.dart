import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/model/subcategory_products_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class RestaurantMenuRepository {
  const RestaurantMenuRepository();

  Future<RestaurantMenuData> fetchMenu({
    required String storeId,
    double latitude = 25.20485,
    double longitude = 55.270782,
    String timezone = 'Asia/Kolkata',
    String cuisineMeatFilter = '1',
  }) async {
    final client = UniversalApiClient.instance.appClient;
    final Map<String, String> queryParams = {
      'containsMeat': cuisineMeatFilter,
      'lat': latitude.toString(),
      'long': longitude.toString(),
      'storeId': storeId,
      'timezone': timezone,
      'z_id': '636dfc8c89b6a857b500ccd1',
    };

    final ApiResult res = await client.get(
      '/get/storeMenu',
      queryParameters: queryParams,
    );

    if (!res.isSuccess || res.data == null) {
      throw Exception(res.message ?? 'Failed to load menu');
    }

    final RestaurantMenuResponse parsed =
        RestaurantMenuResponse.fromJson(res.data as Map<String, dynamic>);
    return parsed.data;
  }

  Future<SubCategoryProductsResponse> fetchSubCategoryProducts({
    required String storeId,
    required String subCategoryId,
  }) async {
    // Get dynamic headers with the provided storeId
    final headers = await UniversalApiClient.instance.buildGroceryHeadersWithStoreId(storeId,subCategoryId);
    
    // Make API call with custom headers
    final ApiResult res = await UniversalApiClient.instance.getWithCustomHeaders(
      '/python/subCategoryProducts/',
      customHeaders: headers,
    );

    try {
      final SubCategoryProductsResponse parsed =
          SubCategoryProductsResponse.fromJson(res.data as Map<String, dynamic>);
      return parsed;
    } catch (e) {
      print('❌ Error parsing SubCategoryProductsResponse: $e');
      print('❌ Raw data type: ${res.data.runtimeType}');
      print('❌ Raw data: ${res.data}');
      throw Exception('Failed to parse subcategory products response: $e');
    }
  }
}


