import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/hotel_availability_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class HotelAvailabilityRepository {
  HotelAvailabilityRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.hotelAvailabilityClient;

  final ApiClient _client;

  static const String _availabilityEndpoint = '/v1/xeni/hotels/availability';

  static Map<String, dynamic> buildRequestBody(Map<String, dynamic> hotelBooking) {
    final occupancy = hotelBooking['occupancy'];
    return {
      'correlationId': (hotelBooking['correlationId'] ?? '').toString(),
      'propertyId': (hotelBooking['propertyId'] ?? '').toString(),
      'checkinDate': (hotelBooking['checkinDate'] ?? '').toString(),
      'checkoutDate': (hotelBooking['checkoutDate'] ?? '').toString(),
      'occupancy': occupancy is List && occupancy.isNotEmpty
          ? occupancy
          : [
              {'adults': 1, 'childs': 0, 'childages': []},
            ],
      'countryOfResidence':
          (hotelBooking['countryOfResidence'] ?? 'AE').toString(),
    };
  }

  Future<ApiResult> fetchAvailability(Map<String, dynamic> hotelBooking) async {
    final body = buildRequestBody(hotelBooking);
    if (body['correlationId'].toString().isEmpty ||
        body['propertyId'].toString().isEmpty ||
        body['checkinDate'].toString().isEmpty ||
        body['checkoutDate'].toString().isEmpty) {
      return ApiResult.error('Missing hotel booking details');
    }

    final result = await _client.post(_availabilityEndpoint, body);
    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to load rooms');
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid availability response');
    }

    try {
      final parsed = HotelAvailabilityResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }
}
