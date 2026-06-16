import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Flight booking summary card (Figma frame 1171285000).
class FlightOrderSummaryWidget extends StatelessWidget {
  final List<FlightOrderSummary> items;
  final Map<String, dynamic> flightBooking;

  const FlightOrderSummaryWidget({
    super.key,
    required this.items,
    this.flightBooking = const {},
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _detailsBackground = Color(0xFFFBF1FF);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _FlightBookingSummaryCard(
                summary: items[i],
                flightBooking: flightBooking,
              ),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlightBookingSummaryCard extends StatelessWidget {
  final FlightOrderSummary summary;
  final Map<String, dynamic> flightBooking;

  const _FlightBookingSummaryCard({
    required this.summary,
    required this.flightBooking,
  });

  @override
  Widget build(BuildContext context) {
    final segments = _allSegments();
    final firstSegment = segments.isNotEmpty ? segments.first : null;
    final lastSegment = segments.isNotEmpty ? segments.last : null;
    final priceLines = _priceLines();
    final promoLine = _promoLine();
    final paymentTitle = _paymentTitle();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 1),
      child: CustomPaint(
        painter: _ReceiptCardPainter(
          borderColor: FlightOrderSummaryWidget._borderColor,
          fillColor: Colors.white,
          topRadius: 16,
          scallopRadius: 6,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking summary',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: FlightOrderSummaryWidget._titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FlightOrderSummaryWidget._detailsBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_airlineLine(firstSegment).isNotEmpty) ...[
                      _SummaryLine(text: _airlineLine(firstSegment)),
                      const SizedBox(height: 10),
                    ],
                    if (_routeTypeLine().isNotEmpty) ...[
                      _SummaryLine(text: _routeTypeLine()),
                      const SizedBox(height: 10),
                    ],
                    if (_travellerLine().isNotEmpty) ...[
                      _SummaryLine(text: _travellerLine()),
                      const SizedBox(height: 10),
                    ],
                    if (_cabinLine(firstSegment).isNotEmpty) ...[
                      _SummaryLine(text: _cabinLine(firstSegment)),
                      const SizedBox(height: 10),
                    ],
                    if (firstSegment != null &&
                        firstSegment.departureAirport.isNotEmpty) ...[
                      _AirportLine(
                        airportCode: firstSegment.departureAirport,
                        airportName: firstSegment.departureAirportName,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (lastSegment != null &&
                        lastSegment.arrivalAirport.isNotEmpty) ...[
                      _AirportLine(
                        airportCode: lastSegment.arrivalAirport,
                        airportName: lastSegment.arrivalAirportName,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_departureDateLine().isNotEmpty) ...[
                      _SummaryLine(text: _departureDateLine()),
                      if (_isRoundTrip && _returnDateLine().isNotEmpty)
                        const SizedBox(height: 10),
                    ],
                    if (_isRoundTrip && _returnDateLine().isNotEmpty)
                      _SummaryLine(text: _returnDateLine()),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...priceLines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PriceRow(
                    label: line.label,
                    amount: line.amount,
                    currency: summary.currencyCode,
                  ),
                ),
              ),
              if (promoLine != null) ...[
                const SizedBox(height: 4),
                const _DashedDivider(
                  color: FlightOrderSummaryWidget._borderColor,
                ),
                const SizedBox(height: 12),
                _PriceRow(
                  label: promoLine.label,
                  amount: promoLine.amount,
                  currency: summary.currencyCode,
                ),
              ],
              const SizedBox(height: 4),
              const _DashedDivider(color: FlightOrderSummaryWidget._borderColor),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Total to pay',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: FlightOrderSummaryWidget._titleColor,
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(summary.currencyCode, summary.totalPrice),
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: FlightOrderSummaryWidget._titleColor,
                    ),
                  ),
                ],
              ),
              if (paymentTitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SummaryLine(text: '💳 $paymentTitle'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<FlightOrderSegment> _allSegments() {
    return summary.flights
        .expand((flight) => flight.flightSegments)
        .toList(growable: false);
  }

  bool get _isRoundTrip {
    final route = summary.tripInfo.routeType.toLowerCase();
    return route.contains('round');
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
    if (normalized.contains('round')) return '🔁 Round Trip';
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
    final segments = _allSegments();
    if (segments.isNotEmpty && segments.first.departureDate.isNotEmpty) {
      return segments.first.departureDate;
    }
    if (summary.tripInfo.travelDate.isNotEmpty) {
      return summary.tripInfo.travelDate;
    }
    return (flightBooking['departure_date'] ?? '').toString();
  }

  String _returnDateRaw() {
    final bookingReturn = (flightBooking['return_date'] ?? '').toString();
    if (bookingReturn.isNotEmpty) return bookingReturn;

    if (summary.flights.length > 1) {
      final returnSegments = summary.flights.last.flightSegments;
      if (returnSegments.isNotEmpty) {
        return returnSegments.last.arrivalDate;
      }
    }

    return '';
  }

  List<_PriceLine> _priceLines() {
    final lines = <_PriceLine>[];

    if (summary.passengerFare.isNotEmpty) {
      for (final fare in summary.passengerFare) {
        if (fare.quantity <= 0) continue;
        lines.add(
          _PriceLine(
            label: _fareLabel(fare),
            amount: fare.totalPrice,
          ),
        );
      }
    } else if (summary.basePrice > 0) {
      final adults = _passengerCount('ADULT');
      final label = adults > 0
          ? 'Base Fare ($adults Adult${adults == 1 ? '' : 's'})'
          : 'Base Fare';
      lines.add(_PriceLine(label: label, amount: summary.basePrice));
    }

    // if (summary.taxAndFees > 0) {
      // lines.add(
      //   _PriceLine(label: 'Taxes & Fees', amount: summary.taxAndFees),
      // );
    // }

    return lines;
  }

  _PriceLine? _promoLine() {
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
    return _PriceLine(label: label, amount: promoAmount);
  }

  String _paymentTitle() {
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

  static String _formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$code$formatted';
  }
}

class _SummaryLine extends StatelessWidget {
  final String text;

  const _SummaryLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyText.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: FlightOrderSummaryWidget._titleColor,
      ),
    );
  }
}

class _AirportLine extends StatelessWidget {
  final String airportCode;
  final String airportName;

  const _AirportLine({
    required this.airportCode,
    required this.airportName,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.bodyText.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: FlightOrderSummaryWidget._titleColor,
    );

    final name = airportName.trim();
    if (name.isEmpty) {
      return Text('📍 $airportCode', style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: '📍 '),
          TextSpan(
            text: airportCode,
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '-$name'),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double? amount;
  final String currency;

  const _PriceRow({
    required this.label,
    this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: FlightOrderSummaryWidget._titleColor,
            ),
          ),
        ),
        if (amount != null) ...[
          const SizedBox(width: 12),
          Text(
            _FlightBookingSummaryCard._formatPrice(currency, amount!),
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: FlightOrderSummaryWidget._titleColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _PriceLine {
  final String label;
  final double? amount;

  const _PriceLine({required this.label, this.amount});
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          thickness: 1,
          dashWidth: 6,
          dashGap: 4,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashGap;

  const _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ReceiptCardPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final double topRadius;
  final double scallopRadius;

  const _ReceiptCardPainter({
    required this.borderColor,
    required this.fillColor,
    this.topRadius = 16,
    this.scallopRadius = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildReceiptPath(
      size,
      topRadius: topRadius,
      scallopRadius: scallopRadius,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ReceiptCardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.topRadius != topRadius ||
        oldDelegate.scallopRadius != scallopRadius;
  }
}

Path _buildReceiptPath(
  Size size, {
  required double topRadius,
  required double scallopRadius,
}) {
  final path = Path();
  final top = topRadius.clamp(0.0, size.width / 2);
  final bottomY = size.height - scallopRadius;

  path.moveTo(0, top);
  path.arcToPoint(
    Offset(top, 0),
    radius: Radius.circular(top),
  );
  path.lineTo(size.width - top, 0);
  path.arcToPoint(
    Offset(size.width, top),
    radius: Radius.circular(top),
  );
  path.lineTo(size.width, bottomY);

  var x = size.width;
  while (x > 0) {
    final nextX = math.max(0.0, x - scallopRadius * 2);
    path.arcToPoint(
      Offset(nextX, bottomY),
      radius: Radius.circular(scallopRadius),
      clockwise: false,
    );
    x = nextX;
  }

  path.lineTo(0, bottomY);
  path.lineTo(0, top);
  path.close();
  return path;
}
