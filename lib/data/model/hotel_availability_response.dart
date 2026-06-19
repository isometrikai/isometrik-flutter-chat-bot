/// Models for POST /v1/xeni/hotels/availability.
class HotelAvailabilityResponse {
  final List<HotelRoom> rooms;

  const HotelAvailabilityResponse({this.rooms = const []});

  factory HotelAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'];
    if (outer is! Map<String, dynamic>) {
      return const HotelAvailabilityResponse();
    }

    final roomsJson = outer['data'];
    if (roomsJson is! List) {
      return const HotelAvailabilityResponse();
    }

    return HotelAvailabilityResponse(
      rooms: roomsJson
          .whereType<Map>()
          .map((e) => HotelRoom.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class HotelRoom {
  final String id;
  final String name;
  final int sleeps;
  final String descriptions;
  final HotelRoomImages images;
  final int availability;
  final List<String> amenities;
  final List<HotelRoomRate> rates;
  final HotelRoomArea area;

  const HotelRoom({
    required this.id,
    required this.name,
    required this.sleeps,
    required this.descriptions,
    required this.images,
    required this.availability,
    required this.amenities,
    required this.rates,
    required this.area,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sleeps: (json['sleeps'] as num?)?.toInt() ?? 0,
      descriptions: (json['descriptions'] ?? '').toString(),
      images: HotelRoomImages.fromJson(
        json['images'] as Map<String, dynamic>? ?? {},
      ),
      availability: (json['availability'] as num?)?.toInt() ?? 0,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rates: (json['rates'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => HotelRoomRate.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      area: HotelRoomArea.fromJson(
        json['area'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  String get thumbnailUrl {
    if (images.thumbnail.isNotEmpty) return images.thumbnail.first;
    if (images.large.isNotEmpty) return images.large.first;
    return '';
  }

  HotelRoomRate? get lowestRate {
    if (rates.isEmpty) return null;
    return rates.reduce(
      (a, b) => a.totalRate <= b.totalRate ? a : b,
    );
  }

  String get recommendationLabel {
    if (sleeps <= 0) return '';
    return 'Recommended for $sleeps ${sleeps == 1 ? 'adult' : 'adults'}';
  }

  List<String> get featureLines {
    final lines = <String>[];
    final rate = lowestRate;
    if (rate != null && rate.beds.isNotEmpty) {
      lines.add(rate.beds.first.name);
    }
    if (area.squareFeet > 0) {
      lines.add('${area.squareFeet} sq ft');
    } else if (area.squareMeters > 0) {
      lines.add('${area.squareMeters} sq m');
    }
    if (rate != null) {
      for (final item in rate.boardBasis) {
        if (item.isNotEmpty && !lines.contains(item)) {
          lines.add(item);
          break;
        }
      }
      for (final item in rate.extras) {
        if (item.isNotEmpty && !lines.contains(item)) {
          lines.add(item);
          break;
        }
      }
    }
    if (lines.length < 4) {
      for (final amenity in amenities) {
        if (amenity.isEmpty || lines.contains(amenity)) continue;
        lines.add(amenity);
        if (lines.length >= 4) break;
      }
    }
    return lines.take(4).toList();
  }
}

class HotelRoomImages {
  final List<String> thumbnail;
  final List<String> small;
  final List<String> large;
  final List<String> extraLarge;

  const HotelRoomImages({
    this.thumbnail = const [],
    this.small = const [],
    this.large = const [],
    this.extraLarge = const [],
  });

  factory HotelRoomImages.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is! List) return const [];
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    return HotelRoomImages(
      thumbnail: parseList(json['thumbnail']),
      small: parseList(json['small']),
      large: parseList(json['large']),
      extraLarge: parseList(json['extra_large']),
    );
  }
}

class HotelRoomArea {
  final int squareMeters;
  final int squareFeet;

  const HotelRoomArea({
    this.squareMeters = 0,
    this.squareFeet = 0,
  });

  factory HotelRoomArea.fromJson(Map<String, dynamic> json) {
    return HotelRoomArea(
      squareMeters: (json['square_meters'] as num?)?.toInt() ?? 0,
      squareFeet: (json['square_feet'] as num?)?.toInt() ?? 0,
    );
  }
}

class HotelRoomRate {
  final bool refundable;
  final double baseRate;
  final double taxAndFees;
  final double totalRate;
  final String currency;
  final double recommendedSellingPrice;
  final double savedPrice;
  final List<String> boardBasis;
  final List<HotelRoomBed> beds;
  final List<String> extras;

  const HotelRoomRate({
    required this.refundable,
    required this.baseRate,
    required this.taxAndFees,
    required this.totalRate,
    required this.currency,
    required this.recommendedSellingPrice,
    required this.savedPrice,
    required this.boardBasis,
    required this.beds,
    required this.extras,
  });

  factory HotelRoomRate.fromJson(Map<String, dynamic> json) {
    return HotelRoomRate(
      refundable: json['refundable'] == true,
      baseRate: (json['base_rate'] as num?)?.toDouble() ?? 0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0,
      totalRate: (json['total_rate'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? '').toString(),
      recommendedSellingPrice:
          (json['recommended_selling_price'] as num?)?.toDouble() ?? 0,
      savedPrice: (json['saved_price'] as num?)?.toDouble() ?? 0,
      boardBasis: (json['board_basis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      beds: (json['beds'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => HotelRoomBed.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class HotelRoomBed {
  final String name;
  final String availabilityToken;

  const HotelRoomBed({
    required this.name,
    required this.availabilityToken,
  });

  factory HotelRoomBed.fromJson(Map<String, dynamic> json) {
    return HotelRoomBed(
      name: (json['name'] ?? '').toString(),
      availabilityToken: (json['availability_token'] ?? '').toString(),
    );
  }
}

/// Selected room + rate for booking continuation.
class HotelRoomSelection {
  final HotelRoom room;
  final HotelRoomRate rate;
  final HotelRoomBed? bed;

  const HotelRoomSelection({
    required this.room,
    required this.rate,
    this.bed,
  });
}
