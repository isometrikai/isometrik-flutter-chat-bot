import '../data/data.dart';
import '../utils/utils.dart';

class FlightOrderSummaryPriceLine {
  final String label;
  final double amount;

  const FlightOrderSummaryPriceLine({
    required this.label,
    required this.amount,
  });
}

sealed class FlightOrderSummaryDetailLine {
  const FlightOrderSummaryDetailLine();
}

class FlightOrderSummaryTextLine extends FlightOrderSummaryDetailLine {
  final String text;

  const FlightOrderSummaryTextLine(this.text);
}

class FlightOrderSummaryAirportLine extends FlightOrderSummaryDetailLine {
  final String airportCode;
  final String airportName;

  const FlightOrderSummaryAirportLine({
    required this.airportCode,
    required this.airportName,
  });
}

/// Resolves display values for [FlightOrderSummaryWidget].
class FlightOrderSummaryViewData {
  final FlightOrderSummary summary;
  final List<FlightOrderSummaryDetailLine> detailLines;
  final List<FlightOrderSummaryPriceLine> priceLines;
  final FlightOrderSummaryPriceLine? promoLine;
  final String paymentTitle;

  const FlightOrderSummaryViewData({
    required this.summary,
    required this.detailLines,
    required this.priceLines,
    required this.promoLine,
    required this.paymentTitle,
  });

  factory FlightOrderSummaryViewData.from({
    required FlightOrderSummary summary,
    Map<String, dynamic> flightBooking = const {},
  }) {
    final resolver = _FlightOrderSummaryResolver(
      summary: summary,
      flightBooking: flightBooking,
    );
    return FlightOrderSummaryViewData(
      summary: summary,
      detailLines: resolver.detailLines,
      priceLines: resolver.priceLines,
      promoLine: resolver.promoLine,
      paymentTitle: resolver.paymentTitle,
    );
  }

  String get currencyCode => summary.currencyCode;

  double get totalPrice => summary.totalPrice;

  static String formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$code$formatted';
  }
}

class _FlightOrderSummaryResolver {
  final FlightOrderSummary summary;
  final Map<String, dynamic> flightBooking;

  const _FlightOrderSummaryResolver({
    required this.summary,
    required this.flightBooking,
  });

  List<FlightOrderSegment> get _outboundSegments {
    if (summary.flights.isEmpty) return const [];
    return summary.flights.first.flightSegments;
  }

  List<FlightOrderSegment> get _returnSegments {
    if (summary.flights.length < 2) return const [];
    return summary.flights[1].flightSegments;
  }

  bool get _isRoundTrip {
    final route = summary.tripInfo.routeType.toLowerCase();
    return route.contains('round') ||
        route.contains('return') ||
        summary.flights.length > 1;
  }

  FlightOrderSegment? get _outboundFirst =>
      _outboundSegments.isNotEmpty ? _outboundSegments.first : null;

  FlightOrderSegment? get _destinationSegment {
    final outbound = _outboundSegments;
    if (outbound.isEmpty) return null;

    if (_isRoundTrip) {
      final origin = summary.tripInfo.tripOrigin.trim().toUpperCase();
      final tripDestination =
          summary.tripInfo.tripDestination.trim().toUpperCase();

      if (origin.isNotEmpty &&
          tripDestination.isNotEmpty &&
          origin == tripDestination) {
        return outbound.last;
      }

      if (tripDestination.isNotEmpty) {
        for (final segment in outbound.reversed) {
          if (segment.arrivalAirport.toUpperCase() == tripDestination) {
            return segment;
          }
        }
      }
    }

    return outbound.last;
  }

  List<FlightOrderSummaryDetailLine> get detailLines {
    final lines = <FlightOrderSummaryDetailLine>[];
    final outboundFirst = _outboundFirst;
    final destinationSegment = _destinationSegment;

    void addText(String text) {
      if (text.isNotEmpty) lines.add(FlightOrderSummaryTextLine(text));
    }

    addText(_airlineLine(outboundFirst));
    addText(_routeTypeLine());
    addText(_travellerLine());
    addText(_cabinLine(outboundFirst));

    if (outboundFirst != null && outboundFirst.departureAirport.isNotEmpty) {
      lines.add(
        FlightOrderSummaryAirportLine(
          airportCode: outboundFirst.departureAirport,
          airportName: outboundFirst.departureAirportName,
        ),
      );
    }

    if (destinationSegment != null &&
        destinationSegment.arrivalAirport.isNotEmpty) {
      lines.add(
        FlightOrderSummaryAirportLine(
          airportCode: destinationSegment.arrivalAirport,
          airportName: destinationSegment.arrivalAirportName,
        ),
      );
    }

    addText(_departureDateLine());
    if (_isRoundTrip) addText(_returnDateLine());

    return lines;
  }

  List<FlightOrderSummaryPriceLine> get priceLines {
    final lines = <FlightOrderSummaryPriceLine>[];

    if (summary.passengerFare.isNotEmpty) {
      for (final fare in summary.passengerFare) {
        if (fare.quantity <= 0) continue;
        final amount = fare.basePrice > 0 ? fare.basePrice : fare.totalPrice;
        if (amount <= 0) continue;
        lines.add(
          FlightOrderSummaryPriceLine(
            label: _fareLabel(fare),
            amount: amount,
          ),
        );
      }
    } else if (summary.basePrice > 0) {
      final adults = _passengerCount('ADULT');
      final label = adults > 0
          ? 'Base Fare ($adults Adult${adults == 1 ? '' : 's'})'
          : 'Base Fare';
      lines.add(
        FlightOrderSummaryPriceLine(label: label, amount: summary.basePrice),
      );
    }

    if (summary.taxAndFees > 0) {
      lines.add(
        FlightOrderSummaryPriceLine(
          label: 'Taxes & Fees',
          amount: summary.taxAndFees,
        ),
      );
    }

    return lines;
  }

  FlightOrderSummaryPriceLine? get promoLine {
    final promoCode = (flightBooking['promo_code'] ??
            flightBooking['promoCode'] ??
            flightBooking['coupon_code'] ??
            '')
        .toString()
        .trim();
    final promoAmount = (flightBooking['promo_discount'] as num?)?.toDouble() ??
        (flightBooking['promoDiscount'] as num?)?.toDouble() ??
        (flightBooking['discount'] as num?)?.toDouble();

    if (promoAmount == null || promoAmount <= 0) return null;

    final label = promoCode.isNotEmpty
        ? 'Promo Discount ($promoCode)'
        : 'Promo Discount';
    return FlightOrderSummaryPriceLine(label: label, amount: promoAmount);
  }

  String get paymentTitle {
    final summaryPayment = summary.payment.cardTitle.trim();
    if (summaryPayment.isNotEmpty) return summaryPayment;

    return [
      flightBooking['paymentTypeText'],
      flightBooking['payment_title'],
      flightBooking['cardTitle'],
      flightBooking['payment_method'],
    ].map((e) => e?.toString().trim() ?? '').firstWhere(
          (e) => e.isNotEmpty,
          orElse: () => '',
        );
  }

  String _airlineLine(FlightOrderSegment? segment) {
    if (segment == null) return '';
    final airline = segment.airlineName.trim();
    final flightNumber = segment.flightNumber.trim();
    if (airline.isEmpty && flightNumber.isEmpty) return '';
    if (flightNumber.isEmpty) return '✈️ $airline';
    if (airline.isEmpty) return '✈️ $flightNumber';
    return '✈️ $airline - $flightNumber';
  }

  String _routeTypeLine() {
    final route = summary.tripInfo.routeType.trim();
    if (route.isEmpty) return '';

    final normalized = route.toLowerCase();
    if (normalized.contains('round') || normalized.contains('return')) {
      return '🔁 Round Trip';
    }
    if (normalized.contains('one')) return '🔁 One Way';
    return '🔁 $route';
  }

  String _travellerLine() {
    final parts = <String>[];

    for (final passenger in summary.passengerTypeQuantity) {
      if (passenger.quantity <= 0) continue;
      switch (passenger.code.toUpperCase()) {
        case 'ADULT':
          parts.add(
            '${passenger.quantity} Adult${passenger.quantity == 1 ? '' : 's'}',
          );
          break;
        case 'CHILD':
          parts.add(
            '${passenger.quantity} Child${passenger.quantity == 1 ? '' : 'ren'}',
          );
          break;
        case 'INFANT':
          parts.add(
            '${passenger.quantity} Infant${passenger.quantity == 1 ? '' : 's'}',
          );
          break;
        default:
          parts.add('${passenger.quantity} ${passenger.code}');
      }
    }

    if (parts.isEmpty) {
      final total = summary.tripInfo.totalTravellers;
      if (total > 0) {
        parts.add('$total Traveller${total == 1 ? '' : 's'}');
      }
    }

    if (parts.isEmpty) return '';
    return '👤 ${parts.join(', ')}';
  }

  String _cabinLine(FlightOrderSegment? segment) {
    final cabin = (segment?.cabinClassText ?? segment?.cabin ?? '').trim();
    if (cabin.isEmpty) {
      final bookingCabin = (flightBooking['cabinType'] ?? '').toString().trim();
      if (bookingCabin.isEmpty) return '';
      return '💺 ${_titleCase(bookingCabin)}';
    }
    return '💺 $cabin';
  }

  String _departureDateLine() {
    final raw = _departureDateRaw();
    if (raw.isEmpty) return '';
    return '🛫 ${Utility.formatHotelDateShort(raw)}';
  }

  String _returnDateLine() {
    final raw = _returnDateRaw();
    if (raw.isEmpty) return '';
    return '🛬 ${Utility.formatHotelDateShort(raw)}';
  }

  String _departureDateRaw() {
    if (_outboundSegments.isNotEmpty &&
        _outboundSegments.first.departureDate.isNotEmpty) {
      return _outboundSegments.first.departureDate;
    }
    if (summary.tripInfo.travelDate.isNotEmpty) {
      return summary.tripInfo.travelDate;
    }
    return (flightBooking['departure_date'] ?? '').toString();
  }

  String _returnDateRaw() {
    final bookingReturn = (flightBooking['return_date'] ?? '').toString();
    if (bookingReturn.isNotEmpty) return bookingReturn;

    final returnSegments = _returnSegments;
    if (returnSegments.isNotEmpty) {
      final lastArrival = returnSegments.last.arrivalDate.trim();
      if (lastArrival.isNotEmpty) return lastArrival;

      final firstDeparture = returnSegments.first.departureDate.trim();
      if (firstDeparture.isNotEmpty) return firstDeparture;
    }

    if (summary.flights.length > 1) {
      final returnFlight = summary.flights.last;
      if (returnFlight.flightSegments.isNotEmpty) {
        final lastSegment = returnFlight.flightSegments.last;
        if (lastSegment.arrivalDate.isNotEmpty) {
          return lastSegment.arrivalDate;
        }
        if (lastSegment.departureDate.isNotEmpty) {
          return lastSegment.departureDate;
        }
      }
    }

    return '';
  }

  int _passengerCount(String code) {
    for (final passenger in summary.passengerTypeQuantity) {
      if (passenger.code.toUpperCase() == code.toUpperCase()) {
        return passenger.quantity;
      }
    }
    return 0;
  }

  String _fareLabel(FlightPassengerFare fare) {
    switch (fare.type.toUpperCase()) {
      case 'ADT':
      case 'ADULT':
        return 'Base Fare (${fare.quantity} Adult${fare.quantity == 1 ? '' : 's'})';
      case 'CHD':
      case 'CHILD':
        return 'Children Fare (${fare.quantity} Child${fare.quantity == 1 ? '' : 'ren'})';
      case 'INF':
      case 'INFANT':
        return 'Infants Fare (${fare.quantity} Infant${fare.quantity == 1 ? '' : 's'})';
      default:
        return '${fare.type} (${fare.quantity})';
    }
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
