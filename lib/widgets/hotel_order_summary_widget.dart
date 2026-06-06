import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Hotel booking summary card (Figma frame 1171285000).
class HotelOrderSummaryWidget extends StatelessWidget {
  final List<HotelOrderSummary> items;
  final Map<String, dynamic> hotelBooking;

  const HotelOrderSummaryWidget({
    super.key,
    required this.items,
    this.hotelBooking = const {},
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
              _BookingSummaryCard(
                summary: items[i],
                hotelBooking: hotelBooking,
              ),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final HotelOrderSummary summary;
  final Map<String, dynamic> hotelBooking;

  const _BookingSummaryCard({
    required this.summary,
    required this.hotelBooking,
  });

  @override
  Widget build(BuildContext context) {
    final nights = _nights();
    final hotelTitle = _hotelTitle();
    final priceLines = _priceLines(nights);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 1),
      child: CustomPaint(
        painter: _ReceiptCardPainter(
          borderColor: HotelOrderSummaryWidget._borderColor,
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
                color: HotelOrderSummaryWidget._titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: HotelOrderSummaryWidget._detailsBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hotelTitle.isNotEmpty) ...[
                    _SummaryLine(text: '🏨 $hotelTitle'),
                    const SizedBox(height: 10),
                  ],
                  if (_dateLine(nights).isNotEmpty) ...[
                    _SummaryLine(text: _dateLine(nights)),
                    const SizedBox(height: 10),
                  ],
                  if (nights != null && nights > 0) ...[
                    _SummaryLine(
                      text:
                          '🌙 $nights night${nights == 1 ? '' : 's'}',
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_guestLine().isNotEmpty) ...[
                    _SummaryLine(text: _guestLine()),
                    const SizedBox(height: 10),
                  ],
                  if (summary.roomName.isNotEmpty)
                    _SummaryLine(text: '🏠 ${_roomLine()}'),
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
                  currency: summary.currency,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const _DashedDivider(color: HotelOrderSummaryWidget._borderColor),
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
                      color: HotelOrderSummaryWidget._titleColor,
                    ),
                  ),
                ),
                Text(
                  _formatPrice(summary.currency, summary.totalPrice),
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: HotelOrderSummaryWidget._titleColor,
                  ),
                ),
              ],
            ),
            if (summary.payment.cardTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SummaryLine(text: '💳 ${summary.payment.cardTitle}'),
            ],
          ],
        ),
      ),
      ),
    );
  }

  int? _nights() {
    final checkin = summary.checkinDate.isNotEmpty
        ? summary.checkinDate
        : (hotelBooking['checkinDate'] ?? '').toString();
    final checkout = summary.checkoutDate.isNotEmpty
        ? summary.checkoutDate
        : (hotelBooking['checkoutDate'] ?? '').toString();

    final checkinDate = Utility.parseHotelBookingDate(checkin);
    final checkoutDate = Utility.parseHotelBookingDate(checkout);
    if (checkinDate == null || checkoutDate == null) return null;

    final nights = checkoutDate.difference(checkinDate).inDays;
    return nights > 0 ? nights : null;
  }

  String _hotelTitle() {
    final name = [
      hotelBooking['hotelName'],
      hotelBooking['hotel_name'],
      hotelBooking['name'],
      hotelBooking['propertyName'],
    ].map((e) => e?.toString().trim() ?? '').firstWhere(
          (e) => e.isNotEmpty,
          orElse: () => '',
        );

    final locationParts = <String>[];
    for (final key in ['location', 'address', 'fullName', 'destination']) {
      final value = hotelBooking[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && !locationParts.contains(value)) {
        locationParts.add(value);
      }
    }
    final city = hotelBooking['city']?.toString().trim() ?? '';
    final state = hotelBooking['state']?.toString().trim() ?? '';
    if (city.isNotEmpty && state.isNotEmpty) {
      locationParts.add('$city, $state');
    } else if (city.isNotEmpty) {
      locationParts.add(city);
    }

    if (name.isEmpty && locationParts.isEmpty) return '';
    if (name.isEmpty) return locationParts.join(', ');
    if (locationParts.isEmpty) return name;
    return '$name, ${locationParts.join(', ')}';
  }

  String _dateLine(int? nights) {
    final checkin = summary.checkinDate.isNotEmpty
        ? summary.checkinDate
        : (hotelBooking['checkinDate'] ?? '').toString();
    final checkout = summary.checkoutDate.isNotEmpty
        ? summary.checkoutDate
        : (hotelBooking['checkoutDate'] ?? '').toString();
    if (checkin.isEmpty || checkout.isEmpty) return '';

    final checkinLabel = Utility.formatHotelDateShort(checkin);
    final checkoutLabel = Utility.formatHotelDateShort(checkout);
    final nightsLabel = nights != null && nights > 0
        ? ' ($nights night${nights == 1 ? '' : 's'})'
        : '';
    return '📅 $checkinLabel → $checkoutLabel$nightsLabel';
  }

  String _guestLine() {
    final label = Utility.formatHotelOccupancyCompact(
      hotelBooking,
      fallbackAdults: summary.numberOfAdults,
    );
    if (label.isEmpty) return '';
    return '👨‍👩‍👧‍👦 $label';
  }

  String _roomLine() {
    final roomCount = Utility.hotelBookingRoomCount(hotelBooking);
    if (roomCount > 1) {
      return '${roomCount}x ${summary.roomName}';
    }
    return summary.roomName;
  }

  List<_PriceLine> _priceLines(int? nights) {
    final lines = <_PriceLine>[];
    final nightsLabel = nights != null && nights > 0
        ? ' ($nights night${nights == 1 ? '' : 's'})'
        : '';
    final roomCount = Utility.hotelBookingRoomCount(hotelBooking);
    final roomLabel = roomCount > 1
        ? '${roomCount}x ${summary.roomName}$nightsLabel'
        : '${summary.roomName}$nightsLabel';

    lines.add(_PriceLine(label: roomLabel, amount: summary.baseRate));

    for (final charge in summary.additionalCharges) {
      final label = (charge['title'] ??
              charge['name'] ??
              charge['description'] ??
              '')
          .toString()
          .trim();
      final amount = (charge['amount'] as num?)?.toDouble() ??
          (charge['price'] as num?)?.toDouble() ??
          (charge['value'] as num?)?.toDouble();
      if (label.isNotEmpty && amount != null) {
        lines.add(_PriceLine(label: label, amount: amount));
      }
    }

    for (final basis in summary.boardBasis) {
      final normalized = basis.trim().toLowerCase();
      if (normalized.isEmpty || normalized == 'room only') continue;
      lines.add(_PriceLine(label: basis.trim()));
    }

    if (summary.taxAndFees > 0) {
      lines.add(
        _PriceLine(label: 'Tax and fees', amount: summary.taxAndFees),
      );
    }

    return lines;
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
        color: HotelOrderSummaryWidget._titleColor,
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
              color: HotelOrderSummaryWidget._titleColor,
            ),
          ),
        ),
        if (amount != null) ...[
          const SizedBox(width: 12),
          Text(
            _BookingSummaryCard._formatPrice(currency, amount!),
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: HotelOrderSummaryWidget._titleColor,
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
