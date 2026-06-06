import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Hotel booking confirmed card (Figma frame 1171284999).
class HotelBookingConfirmedWidget extends StatelessWidget {
  final List<WidgetAction> items;

  const HotelBookingConfirmedWidget({
    super.key,
    required this.items,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);

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
              if (items[i].title.trim().isNotEmpty)
                _ConfirmedCard(title: items[i].title.trim()),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  final String title;

  const _ConfirmedCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: HotelBookingConfirmedWidget._borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyText.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: HotelBookingConfirmedWidget._titleColor,
        ),
      ),
    );
  }
}
