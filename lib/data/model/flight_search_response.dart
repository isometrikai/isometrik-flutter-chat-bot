import 'package:chat_bot/data/model/chat_response.dart';

/// Models for POST /v1/xeni/flights/search.
class FlightSearchResponse {
  final int total;
  final List<FlightSearch> flights;

  const FlightSearchResponse({
    this.total = 0,
    this.flights = const [],
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    var correlationId = (json['correlationId'] ?? '').toString();
    final outer = json['data'];

    if (outer is Map<String, dynamic>) {
      if (correlationId.isEmpty) {
        correlationId = (outer['correlationId'] ?? '').toString();
      }

      final inner = outer['data'];
      if (inner is Map<String, dynamic>) {
        return _fromInnerMap(inner, correlationId);
      }

      final directList = outer['flights'] ?? outer['results'];
      if (directList is List) {
        final flights = _parseFlights(directList, correlationId);
        return FlightSearchResponse(
          total: (outer['total_count'] as num?)?.toInt() ??
              (outer['total'] as num?)?.toInt() ??
              flights.length,
          flights: flights,
        );
      }
    }

    final rootList = json['flights'] ?? json['results'];
    if (rootList is List) {
      final flights = _parseFlights(rootList, correlationId);
      return FlightSearchResponse(
        total: (json['total_count'] as num?)?.toInt() ??
            (json['total'] as num?)?.toInt() ??
            flights.length,
        flights: flights,
      );
    }

    return const FlightSearchResponse();
  }

  static FlightSearchResponse _fromInnerMap(
    Map<String, dynamic> inner,
    String correlationId,
  ) {
    final flightsJson = inner['flights'] ?? inner['results'];
    final flights = _parseFlights(flightsJson, correlationId);

    return FlightSearchResponse(
      total: (inner['total_count'] as num?)?.toInt() ??
          (inner['total'] as num?)?.toInt() ??
          flights.length,
      flights: flights,
    );
  }

  static List<FlightSearch> _parseFlights(
    dynamic raw,
    String correlationId,
  ) {
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      if (correlationId.isNotEmpty &&
          (map['correlation_id'] == null || map['correlation_id'] == '') &&
          (map['correlationId'] == null || map['correlationId'] == '')) {
        map['correlation_id'] = correlationId;
      }
      return FlightSearch.fromJson(map);
    }).toList();
  }
}
