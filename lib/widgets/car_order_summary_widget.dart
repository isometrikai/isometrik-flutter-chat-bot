import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Car rental booking summary card (Figma frame 1171285000).
class CarOrderSummaryWidget extends StatelessWidget {
  final List<CarOrderSummary> items;
  final Map<String, dynamic> carBooking;

  const CarOrderSummaryWidget({
    super.key,
    required this.items,
    this.carBooking = const {},
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _detailsBackground = Color(0xFFFBF1FF);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _CarBookingSummaryCard(
                summary: items[i],
                carBooking: carBooking,
              ),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarBookingSummaryCard extends StatelessWidget {
  final CarOrderSummary summary;
  final Map<String, dynamic> carBooking;

  const _CarBookingSummaryCard({
    required this.summary,
    required this.carBooking,
  });

  @override
  Widget build(BuildContext context) {
    final days = _days();
    final vehicleLine = _vehicleLine();
    final dateLine = _dateLine(days);
    final locationLine = _locationLine();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.5, 0.5, 0.5, 1),
      child: CustomPaint(
        painter: _ReceiptCardPainter(
          borderColor: CarOrderSummaryWidget._borderColor,
          fillColor: Colors.white,
          topRadius: 16,
          scallopRadius: 6,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15, 20, 15, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.bookingSummary,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: CarOrderSummaryWidget._titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CarOrderSummaryWidget._detailsBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicleLine.isNotEmpty) ...[
                      _SummaryLine(text: '🚘 $vehicleLine'),
                      const SizedBox(height: 10),
                    ],
                    if (dateLine.isNotEmpty) ...[
                      _SummaryLine(text: dateLine),
                      const SizedBox(height: 10),
                    ],
                    if (locationLine.isNotEmpty)
                      _SummaryLine(text: '📍 $locationLine'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _DashedDivider(color: CarOrderSummaryWidget._borderColor),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.totalToPay,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: CarOrderSummaryWidget._titleColor,
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(summary.currencyCode, summary.totalPrice),
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: CarOrderSummaryWidget._titleColor,
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

  int? _days() {
    final pickup = _pickupDate();
    final returnDate = _returnDate();

    final pickupDt = Utility.parseHotelBookingDate(pickup);
    final returnDt = Utility.parseHotelBookingDate(returnDate);
    if (pickupDt == null || returnDt == null) return null;

    final days = returnDt.difference(pickupDt).inDays;
    return days > 0 ? days : null;
  }

  String _pickupDate() {
    if (summary.pickUpDateTime.isNotEmpty) return summary.pickUpDateTime;
    if (summary.pickupDate.isNotEmpty) return summary.pickupDate;
    return (carBooking['pickup_date'] ?? '').toString();
  }

  String _returnDate() {
    if (summary.returnDateTime.isNotEmpty) return summary.returnDateTime;
    if (summary.returnDate.isNotEmpty) return summary.returnDate;
    return (carBooking['return_date'] ?? '').toString();
  }

  String _vehicleLine() {
    final carName = summary.carName?.trim() ?? '';
    if (carName.isNotEmpty) return carName;

    final vehicleName = summary.vehicle.name.trim();
    if (vehicleName.isNotEmpty) return vehicleName;

    return (carBooking['car_name'] ?? '').toString().trim();
  }

  String _dateLine(int? days) {
    final pickup = _pickupDate();
    final returnDate = _returnDate();
    if (pickup.isEmpty || returnDate.isEmpty) return '';

    final pickupLabel = Utility.formatHotelDateShort(pickup);
    final returnLabel = Utility.formatHotelDateShort(returnDate);

    if (days != null && days > 0) {
      return '📅 ${AppTranslations.forNDays(days.toString())} ($pickupLabel - $returnLabel)';
    }
    return '📅 $pickupLabel - $returnLabel';
  }

  String _locationLine() {
    if (summary.locationDetails.isNotEmpty) {
      final pickup = _locationLabel(summary.locationDetails.first);
      if (summary.locationDetails.length < 2) return pickup;

      final dropoff = _locationLabel(summary.locationDetails[1]);
      if (pickup.isEmpty && dropoff.isEmpty) return '';
      if (dropoff.isEmpty) return pickup;
      if (pickup.isEmpty) return dropoff;
      return '$pickup - $dropoff';
    }

    final pickupCode = summary.pickupCode.isNotEmpty
        ? summary.pickupCode
        : (carBooking['pickup_code'] ?? '').toString();
    final returnCode = summary.returnCode.isNotEmpty
        ? summary.returnCode
        : (carBooking['return_code'] ?? '').toString();

    if (pickupCode.isEmpty && returnCode.isEmpty) return '';
    if (returnCode.isEmpty || pickupCode == returnCode) return pickupCode;
    return '$pickupCode - $returnCode';
  }

  String _locationLabel(CarRentalLocationDetail location) {
    final city = location.address.city.trim();
    final name = location.name.trim();

    if (name.isNotEmpty && city.isNotEmpty && name != city) {
      return '$name, $city';
    }
    if (city.isNotEmpty) return city;
    return name;
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
        color: CarOrderSummaryWidget._titleColor,
      ),
    );
  }
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
