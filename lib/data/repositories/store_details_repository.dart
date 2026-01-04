import 'package:chat_bot/data/model/store_details_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class StoreDetailsRepository {
  const StoreDetailsRepository();

  Future<StoreDetailsData> fetchStoreDetails({
    required String storeId,
    required double latitude,
    required double longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    final client = UniversalApiClient.instance.appClient;
    final Map<String, String> queryParams = {
      'lat': latitude.toString(),
      'long': longitude.toString(),
      's_id': storeId,
      'timezone': timezone,
    };

    final ApiResult res = await client.get(
      '/python/store/details',
      queryParameters: queryParams,
    );

    if (!res.isSuccess || res.data == null) {
      throw Exception(res.message ?? 'Failed to load store details');
    }

    final StoreDetailsResponse parsed = StoreDetailsResponse.fromJson(
      res.data as Map<String, dynamic>,
    );
    return parsed.data;
  }
}

