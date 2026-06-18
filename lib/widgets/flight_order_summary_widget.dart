import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';
import 'flight_order_summary_view_data.dart';

/// Flight booking summary card (Figma frame 1171285000).
class FlightOrderSummaryWidget extends StatelessWidget {
  final List<FlightOrderSummary> items;
  final Map<String, dynamic> flightBooking;

  const FlightOrderSummaryWidget({
    super.key,
    required this.items,
    this.flightBooking = const {},
  });

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
                viewData: FlightOrderSummaryViewData.from(
                  summary: items[i],
                  flightBooking: flightBooking,
                ),
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
  final FlightOrderSummaryViewData viewData;

  const _FlightBookingSummaryCard({required this.viewData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 1),
      child: CustomPaint(
        painter: _ReceiptCardPainter(
          borderColor: _FlightOrderSummaryTheme.borderColor,
          fillColor: Colors.white,
          topRadius: 16,
          scallopRadius: 6,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking summary', style: _FlightOrderSummaryTheme.sectionTitle),
              const SizedBox(height: 8),
              _DetailsPanel(lines: viewData.detailLines),
              const SizedBox(height: 12),
              _PriceBreakdown(viewData: viewData),
              if (viewData.paymentTitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SummaryLine(text: '💳 ${viewData.paymentTitle}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final List<FlightOrderSummaryDetailLine> lines;

  const _DetailsPanel({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _FlightOrderSummaryTheme.detailsBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < lines.length; i++) ...[
            _DetailLineWidget(line: lines[i]),
            if (i < lines.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DetailLineWidget extends StatelessWidget {
  final FlightOrderSummaryDetailLine line;

  const _DetailLineWidget({required this.line});

  @override
  Widget build(BuildContext context) {
    return switch (line) {
      FlightOrderSummaryTextLine(:final text) => _SummaryLine(text: text),
      FlightOrderSummaryAirportLine(
        :final airportCode,
        :final airportName,
      ) =>
        _AirportLine(
          airportCode: airportCode,
          airportName: airportName,
        ),
    };
  }
}

class _PriceBreakdown extends StatelessWidget {
  final FlightOrderSummaryViewData viewData;

  const _PriceBreakdown({required this.viewData});

  @override
  Widget build(BuildContext context) {
    final promoLine = viewData.promoLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in viewData.priceLines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PriceRow(
              label: line.label,
              amount: line.amount,
              currency: viewData.currencyCode,
            ),
          ),
        if (promoLine != null) ...[
          const SizedBox(height: 4),
          const _DashedDivider(color: _FlightOrderSummaryTheme.borderColor),
          const SizedBox(height: 12),
          _PriceRow(
            label: promoLine.label,
            amount: promoLine.amount,
            currency: viewData.currencyCode,
          ),
        ],
        const SizedBox(height: 4),
        const _DashedDivider(color: _FlightOrderSummaryTheme.borderColor),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Total to pay',
                style: _FlightOrderSummaryTheme.sectionTitle,
              ),
            ),
            Text(
              FlightOrderSummaryViewData.formatPrice(
                viewData.currencyCode,
                viewData.totalPrice,
              ),
              style: _FlightOrderSummaryTheme.sectionTitle,
            ),
          ],
        ),
      ],
    );
  }
}

abstract final class _FlightOrderSummaryTheme {
  static const Color borderColor = Color(0xFFE9DFFB);
  static const Color titleColor = Color(0xFF242424);
  static const Color detailsBackground = Color(0xFFFBF1FF);

  static TextStyle get sectionTitle => AppTextStyles.bodyText.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: titleColor,
      );

  static TextStyle get bodyLine => AppTextStyles.bodyText.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: titleColor,
      );

  static TextStyle get priceLabel => AppTextStyles.bodyText.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: titleColor,
      );
}

class _SummaryLine extends StatelessWidget {
  final String text;

  const _SummaryLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _FlightOrderSummaryTheme.bodyLine);
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
    final baseStyle = _FlightOrderSummaryTheme.bodyLine;
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
          child: Text(label, style: _FlightOrderSummaryTheme.priceLabel),
        ),
        if (amount != null) ...[
          const SizedBox(width: 12),
          Text(
            FlightOrderSummaryViewData.formatPrice(currency, amount!),
            style: _FlightOrderSummaryTheme.priceLabel,
          ),
        ],
      ],
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
