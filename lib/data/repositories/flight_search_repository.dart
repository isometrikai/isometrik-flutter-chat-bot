import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/flight_search_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class FlightSearchRepository {
  FlightSearchRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.hotelAvailabilityClient;

  final ApiClient _client;

  static const String _searchEndpoint = '/v1/xeni/flights/search';
  static const int defaultPageLimit = 10;

  static Map<String, dynamic> buildRequestBody({
    required WidgetAction action,
    Map<String, dynamic>? flightBooking,
    int page = 1,
    int limit = defaultPageLimit,
  }) {
    final routeType = resolveRouteType(action, flightBooking);
    final flightInfo = resolveFlightInfo(action, flightBooking, routeType);

    return {
      'flightInfo': flightInfo,
      'routeType': routeType,
      'cabinType': resolveCabinType(action, flightBooking),
      'adults': resolvePassengerCount(action.adults, flightBooking?['adults'], defaultValue: 1),
      'children': resolvePassengerCount(action.children, flightBooking?['children']),
      'infants': resolvePassengerCount(action.infants, flightBooking?['infants']),
      'pagination': {
        'page': page,
        'limit': limit,
      },
    };
  }

  static String resolveRouteType(
    WidgetAction action,
    Map<String, dynamic>? flightBooking,
  ) {
    final fromAction = (action.routeType ?? action.tripType ?? '').trim();
    if (fromAction.isNotEmpty) {
      return normalizeRouteType(fromAction);
    }

    if (flightBooking != null) {
      final fromBooking = (flightBooking['routeType'] ??
              flightBooking['route_type'] ??
              flightBooking['trip_type'] ??
              '')
          .toString()
          .trim();
      if (fromBooking.isNotEmpty) {
        return normalizeRouteType(fromBooking);
      }
    }

    return 'oneway';
  }

  static String normalizeRouteType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'return' ||
        normalized == 'roundtrip' ||
        normalized == 'round_trip' ||
        normalized == 'round-trip') {
      return 'return';
    }
    return 'oneway';
  }

  static String resolveCabinType(
    WidgetAction action,
    Map<String, dynamic>? flightBooking,
  ) {
    final fromAction = (action.cabinType ?? '').trim();
    if (fromAction.isNotEmpty) return fromAction;

    if (flightBooking != null) {
      final fromBooking = (flightBooking['cabinType'] ??
              flightBooking['cabin_type'] ??
              '')
          .toString()
          .trim();
      if (fromBooking.isNotEmpty) return fromBooking;
    }

    return 'economy';
  }

  static int resolvePassengerCount(
    int? fromAction,
    dynamic fromBooking, {
    int defaultValue = 0,
  }) {
    if (fromAction != null && fromAction > 0) return fromAction;
    if (fromBooking is num && fromBooking.toInt() > 0) {
      return fromBooking.toInt();
    }
    return defaultValue;
  }

  static List<Map<String, dynamic>> resolveFlightInfo(
    WidgetAction action,
    Map<String, dynamic>? flightBooking,
    String routeType,
  ) {
    if (action.flightInfo != null && action.flightInfo!.isNotEmpty) {
      return action.flightInfo!.map((info) => info.toJson()).toList();
    }

    if (flightBooking == null) return [];

    final origin = (flightBooking['flight_origin'] ??
            flightBooking['origin'] ??
            '')
        .toString();
    final destination = (flightBooking['flight_destination'] ??
            flightBooking['destination'] ??
            '')
        .toString();
    final departureDate = (flightBooking['departure_date'] ?? '').toString();
    final returnDate = (flightBooking['return_date'] ?? '').toString();

    if (origin.isEmpty || destination.isEmpty || departureDate.isEmpty) {
      return [];
    }

    final flightInfo = <Map<String, dynamic>>[
      {
        'departureDate': departureDate,
        'origin': origin,
        'destination': destination,
      },
    ];

    if (routeType == 'return' && returnDate.isNotEmpty) {
      flightInfo.add({
        'departureDate': returnDate,
        'origin': destination,
        'destination': origin,
      });
    }

    return flightInfo;
  }

  Future<ApiResult> searchFlights({
    required WidgetAction action,
    Map<String, dynamic>? flightBooking,
    int page = 1,
    int limit = defaultPageLimit,
  }) async {
    final body = buildRequestBody(
      action: action,
      flightBooking: flightBooking,
      page: page,
      limit: limit,
    );
    final flightInfo = body['flightInfo'] as List<dynamic>;

    if (flightInfo.isEmpty) {
      return ApiResult.error('Missing flight search details');
    }

    final result = await _client.post(_searchEndpoint, body);
    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to search flights');
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid flight search response');
    }

    try {
      final parsed = FlightSearchResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }
}
