import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/hotel_search_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class HotelSearchRepository {
  HotelSearchRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.hotelAvailabilityClient;

  final ApiClient _client;

  static const String _searchEndpoint = '/v1/xeni/hotels/search';

  static Map<String, dynamic> buildRequestBody({
    required WidgetAction action,
    String searchName = '',
  }) {
    final occupancy = action.occupancy;
    final sort = action.sort;

    final body = <String, dynamic>{
      'lat': action.lat?.toDouble() ?? 0.0,
      'long': action.lng?.toDouble() ?? 0.0,
      'radius': 0,
      'countryOfResidence': (action.countryOfResidence ?? 'AE').toString(),
      'sort': (sort != null && sort.isNotEmpty)
          ? sort
          : [
              {'key': 'price', 'order': 'desc'},
            ],
      'isAsync': action.isAsync ?? false,
      'occupancy': (occupancy != null && occupancy.isNotEmpty)
          ? occupancy
          : [
              {'adults': 2, 'childs': 0, 'childages': []},
            ],
      'checkinDate': (action.checkinDate ?? '').toString(),
      'checkoutDate': (action.checkoutDate ?? '').toString(),
    };

    if (searchName.trim().isNotEmpty) {
      body['filters'] = {'name': searchName.trim()};
    }

    return body;
  }

  Future<ApiResult> searchHotels({
    required WidgetAction action,
    String searchName = '',
  }) async {
    final body = buildRequestBody(action: action, searchName: searchName);

    if (body['checkinDate'].toString().isEmpty ||
        body['checkoutDate'].toString().isEmpty) {
      return ApiResult.error('Missing hotel booking dates');
    }

    final result = await _client.post(_searchEndpoint, body);
    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to search hotels');
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid hotel search response');
    }

    try {
      final parsed = HotelSearchResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }
}
