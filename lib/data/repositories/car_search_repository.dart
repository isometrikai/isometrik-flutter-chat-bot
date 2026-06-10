import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/car_search_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/utils/utility.dart';

class CarSearchRepository {
  CarSearchRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.hotelAvailabilityClient;

  final ApiClient _client;

  static const String _searchEndpoint = '/v1/xeni/cars/rentals';

  static Map<String, String> buildQueryParameters({
    required WidgetAction action,
  }) {
    final params = <String, String>{
      'country': (action.country ?? 'AE').toString(),
      'pickup_date': (action.pickupDate ?? '').toString(),
      'return_date': (action.returnDate ?? '').toString(),
      'pickup_type': (action.pickupType ?? 'iata').toString(),
      'return_type': (action.returnType ?? 'iata').toString(),
      'pickup_code': (action.pickupCode ?? '').toString(),
      'return_code': (action.returnCode ?? '').toString(),
      'currency': (action.currency ?? Utility.getCurrencyCode()).toString(),
      'page': '${action.page ?? 1}',
      'limit': '${action.limit ?? 50}',
      'driver_age': '${action.driverAge ?? 25}',
    };

    final pickupGeo = (action.pickupGeo ?? '').toString().trim();
    if (pickupGeo.isNotEmpty) {
      params['pickup_geo'] = pickupGeo;
    }

    final correlationId = (action.correlationId ?? '').toString().trim();
    if (correlationId.isNotEmpty) {
      params['correlationId'] = correlationId;
    }

    return params;
  }

  Future<ApiResult> searchCars({
    required WidgetAction action,
  }) async {
    final queryParameters = buildQueryParameters(action: action);

    if (queryParameters['pickup_date']?.isEmpty ?? true) {
      return ApiResult.error('Missing car pickup date');
    }
    if (queryParameters['return_date']?.isEmpty ?? true) {
      return ApiResult.error('Missing car return date');
    }

    final result = await _client.get(
      _searchEndpoint,
      queryParameters: queryParameters,
    );
    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to search cars');
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid car search response');
    }

    try {
      final parsed = CarSearchResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }
}
