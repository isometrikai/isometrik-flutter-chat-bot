import 'package:chat_bot/data/model/chat_response.dart';

/// Models for GET /v1/xeni/cars/rentals.
class CarSearchResponse {
  final int total;
  final List<CarRentalSearch> rentals;

  const CarSearchResponse({
    this.total = 0,
    this.rentals = const [],
  });

  factory CarSearchResponse.fromJson(Map<String, dynamic> json) {
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

      final directList = outer['available_cars'] ??
          outer['rentals'] ??
          outer['cars'] ??
          outer['vehicles'];
      if (directList is List) {
        final rentals = _parseRentals(directList, correlationId);
        return CarSearchResponse(
          total: (outer['total_count'] as num?)?.toInt() ??
              (outer['total'] as num?)?.toInt() ??
              rentals.length,
          rentals: rentals,
        );
      }
    }

    final rootList = json['available_cars'] ??
        json['rentals'] ??
        json['cars'] ??
        json['vehicles'];
    if (rootList is List) {
      final rentals = _parseRentals(rootList, correlationId);
      return CarSearchResponse(
        total: (json['total_count'] as num?)?.toInt() ??
            (json['total'] as num?)?.toInt() ??
            rentals.length,
        rentals: rentals,
      );
    }

    return const CarSearchResponse();
  }

  static CarSearchResponse _fromInnerMap(
    Map<String, dynamic> inner,
    String correlationId,
  ) {
    final pickupDate = (inner['pick_up_date_time'] ??
            inner['pickup_date'] ??
            '')
        .toString();
    final returnDate = (inner['return_date_time'] ??
            inner['return_date'] ??
            '')
        .toString();

    final availableCars = inner['available_cars'];
    if (availableCars is List) {
      final rentals = _parseRentals(
        availableCars,
        correlationId,
        pickupDate: pickupDate,
        returnDate: returnDate,
      );
      return CarSearchResponse(
        total: (inner['total_count'] as num?)?.toInt() ?? rentals.length,
        rentals: rentals,
      );
    }

    final rentals = _parseRentals(
      inner['rentals'] ??
          inner['cars'] ??
          inner['vehicles'] ??
          inner['results'],
      correlationId,
      pickupDate: pickupDate,
      returnDate: returnDate,
    );

    return CarSearchResponse(
      total: (inner['total_count'] as num?)?.toInt() ??
          (inner['total'] as num?)?.toInt() ??
          rentals.length,
      rentals: rentals,
    );
  }

  static List<CarRentalSearch> _parseRentals(
    dynamic raw,
    String correlationId, {
    String pickupDate = '',
    String returnDate = '',
  }) {
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);

      return CarRentalSearch.fromAvailabilityJson(
        map,
        correlationId: correlationId,
        pickupDate: pickupDate,
        returnDate: returnDate,
      );
    }).toList();
  }
}
