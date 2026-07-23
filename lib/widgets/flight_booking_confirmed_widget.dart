import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Flight booking confirmed card (matches car/hotel confirmed layout, no IDs).
class FlightBookingConfirmedWidget extends StatelessWidget {
  final List<WidgetAction> items;

  const FlightBookingConfirmedWidget({
    super.key,
    required this.items,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _subtitleColor = Color(0xFF6B6B6B);

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
              _ConfirmedCard(item: items[i]),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  final WidgetAction item;

  const _ConfirmedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item.title.trim();
    final subtitle = item.subtitle.replaceAll('DUMMY-FLIGHT-ORDER-ID', '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(15, 20, 15, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FlightBookingConfirmedWidget._borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: FlightBookingConfirmedWidget._titleColor,
              ),
            ),
          if (subtitle.isNotEmpty) ...[
            if (title.isNotEmpty) const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: FlightBookingConfirmedWidget._subtitleColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
