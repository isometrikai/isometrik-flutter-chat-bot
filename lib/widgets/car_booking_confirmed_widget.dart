import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Car booking confirmed card (matches hotel booking confirmed layout).
class CarBookingConfirmedWidget extends StatelessWidget {
  final List<WidgetAction> items;

  const CarBookingConfirmedWidget({
    super.key,
    required this.items,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _subtitleColor = Color(0xFF6B6B6B);
  static const Color _detailsBackground = Color(0xFFFBF1FF);
  static const Color _labelColor = Color(0xFF6B6B6B);

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
    final bookingId = item.booking_id?.trim() ?? '';
    final orderId = item.orderId?.trim() ?? '';
    final title = item.title.trim();
    final subtitle = item.subtitle.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(15, 20, 15, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CarBookingConfirmedWidget._borderColor),
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
                color: CarBookingConfirmedWidget._titleColor,
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
                color: CarBookingConfirmedWidget._subtitleColor,
              ),
            ),
          ],
          if (bookingId.isNotEmpty || orderId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CarBookingConfirmedWidget._detailsBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bookingId.isNotEmpty) ...[
                    _IdRow(label: AppTranslations.bookingId, value: bookingId),
                    if (orderId.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (orderId.isNotEmpty)
                    _IdRow(label: AppTranslations.orderId, value: orderId),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IdRow extends StatelessWidget {
  final String label;
  final String value;

  const _IdRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: CarBookingConfirmedWidget._labelColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: CarBookingConfirmedWidget._titleColor,
          ),
        ),
      ],
    );
  }
}
