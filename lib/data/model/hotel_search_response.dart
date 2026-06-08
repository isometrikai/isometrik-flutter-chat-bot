import 'package:chat_bot/data/model/chat_response.dart';

/// Models for POST /v1/xeni/hotels/search.
class HotelSearchResponse {
  final int total;
  final List<HotelProperty> hotels;
  final double maxDistance;

  const HotelSearchResponse({
    this.total = 0,
    this.hotels = const [],
    this.maxDistance = 0,
  });

  factory HotelSearchResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'];
    final correlationId = (json['correlationId'] ?? '').toString();
    if (outer is! Map<String, dynamic>) {
      return const HotelSearchResponse();
    }

    final inner = outer['data'];
    if (inner is! Map<String, dynamic>) {
      return const HotelSearchResponse();
    }

    final hotelsJson = inner['hotels'];
    final hotels = hotelsJson is List
        ? hotelsJson
            .whereType<Map>()
            .map((e) {
              final map = Map<String, dynamic>.from(e);
              if (correlationId.isNotEmpty) {
                map['correlation_id'] = correlationId;
              }
              return HotelProperty.fromJson(map);
            })
            .toList()
        : <HotelProperty>[];

    return HotelSearchResponse(
      total: (inner['total'] as num?)?.toInt() ?? hotels.length,
      hotels: hotels,
      maxDistance: (inner['max_distance'] as num?)?.toDouble() ?? 0,
    );
  }
}
