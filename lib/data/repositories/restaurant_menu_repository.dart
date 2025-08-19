import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class RestaurantMenuRepository {
  const RestaurantMenuRepository();

  Future<List<ProductCategory>> fetchMenu({
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
    return parsed.data.productData;
  }
}


